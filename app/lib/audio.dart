import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Sfx { tap, bell, door }

const _musicVolume = 0.35;
const _mutedKey = 'suara_mati';

/// Musik dan efek berbunyi bersamaan. Tanpa ini setiap efek merebut audio focus di Android
/// dan musik dihentikan sistem.
final _mixContext = AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build();

Future<void> _mix(AudioPlayer p) async {
  try {
    await p.setAudioContext(_mixContext);
  } catch (_) {
    // Platform tanpa konsep audio focus (misalnya web) menolak, dan itu tidak apa-apa.
  }
}

/// Suara latar dan efek. Pemanggil tidak perlu tahu apakah suara sungguhan atau senyap.
abstract class AudioService extends ChangeNotifier {
  /// Diisi AppShell supaya layar mana pun bisa memutar efek tanpa meneruskan objek ini.
  static AudioService current = SilentAudio();

  bool get muted;

  /// Boleh dipanggil berulang, termasuk dari ketukan pertama pengguna (browser menolak suara otomatis).
  Future<void> startMusic();
  void sfx(Sfx s);
  Future<void> setMuted(bool value);

  /// Aplikasi pindah ke latar belakang.
  void pause();
  void resume();
}

/// Dipakai di pengujian: tidak mengeluarkan suara, hanya mencatat apa yang diminta.
class SilentAudio extends AudioService {
  bool _muted = false;
  bool musicWanted = false;
  final List<Sfx> played = [];

  @override
  bool get muted => _muted;

  @override
  Future<void> startMusic() async => musicWanted = true;

  @override
  void sfx(Sfx s) {
    if (!_muted) played.add(s);
  }

  @override
  Future<void> setMuted(bool value) async {
    _muted = value;
    notifyListeners();
  }

  @override
  void pause() {}
  @override
  void resume() {}
}

class PlayerAudio extends AudioService {
  final AudioPlayer _music = AudioPlayer();
  final Map<Sfx, AudioPlayer> _fx = {};
  bool _muted = false;
  bool _wantMusic = false;
  bool _backgrounded = false;
  bool _playing = false;
  bool _loaded = false;
  bool _busy = false;
  bool _again = false;
  Timer? _fade;

  @override
  bool get muted => _muted;

  /// Membaca pilihan bisu yang tersimpan.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _muted = prefs.getBool(_mutedKey) ?? false;
    } catch (_) {
      // Tanpa penyimpanan, suara tetap nyala secara bawaan.
    }
  }

  @override
  Future<void> startMusic() {
    debugPrint('[audio] startMusic (bisu=$_muted, latar=$_backgrounded, main=$_playing)');
    _wantMusic = true;
    return _apply();
  }

  Future<void> _apply() async {
    if (_busy) {
      _again = true; // keadaan berubah saat sedang bekerja: ulangi setelah selesai
      return;
    }
    _busy = true;
    try {
      do {
        _again = false;
        await _applyOnce();
      } while (_again);
    } finally {
      _busy = false;
    }
  }

  Future<void> _applyOnce() async {
    try {
      final should = _wantMusic && !_muted && !_backgrounded;
      if (should && !_playing) {
        if (_loaded) {
          await _music.resume();
        } else {
          await _mix(_music);
          await _music.setReleaseMode(ReleaseMode.loop);
          await _music.setVolume(0);
          if (kDebugMode) _music.onPlayerStateChanged.listen((s) => debugPrint('[audio] status musik: $s'));
          await _music.play(AssetSource('audio/ambient_hall.wav'));
          debugPrint('[audio] play() selesai');
          _loaded = true;
        }
        _playing = true;
        _fadeTo(_musicVolume);
      } else if (!should && _playing) {
        _fade?.cancel();
        await _music.pause();
        _playing = false;
      }
    } catch (e) {
      // Browser menolak suara sebelum ada ketukan: coba lagi pada ketukan berikutnya.
      debugPrint('[audio] musik gagal diputar: $e');
      _playing = false;
      _loaded = false;
    }
  }

  void _fadeTo(double target) {
    _fade?.cancel();
    var v = 0.0;
    _fade = Timer.periodic(const Duration(milliseconds: 100), (t) async {
      v = (v + 0.03).clamp(0.0, target);
      try {
        await _music.setVolume(v);
      } catch (_) {
        t.cancel();
      }
      if (v >= target) t.cancel();
    });
  }

  @override
  void sfx(Sfx s) {
    if (_muted) return;
    final name = switch (s) {
      Sfx.tap => 'tap',
      Sfx.bell => 'bell',
      Sfx.door => 'door',
    };
    final vol = switch (s) {
      Sfx.tap => 0.5,
      Sfx.bell => 0.7,
      Sfx.door => 0.8,
    };
    unawaited(() async {
      try {
        var p = _fx[s];
        if (p == null) {
          p = _fx[s] = AudioPlayer();
          await _mix(p);
          await p.setPlayerMode(PlayerMode.lowLatency);
        }
        await p.stop();
        await p.play(AssetSource('audio/$name.wav'), volume: vol);
      } catch (e) {
        // Efek suara hanya pemanis; gagal diam-diam.
        debugPrint('[audio] efek $name gagal: $e');
      }
    }());
  }

  @override
  Future<void> setMuted(bool value) async {
    _muted = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_mutedKey, value);
    } catch (_) {
      // Pilihan tidak tersimpan, tapi berlaku selama aplikasi terbuka.
    }
    await _apply();
  }

  @override
  void pause() {
    _backgrounded = true;
    unawaited(_apply());
  }

  @override
  void resume() {
    _backgrounded = false;
    unawaited(_apply());
  }

  @override
  void dispose() {
    _fade?.cancel();
    _music.dispose();
    for (final p in _fx.values) {
      p.dispose();
    }
    super.dispose();
  }
}
