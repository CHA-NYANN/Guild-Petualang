import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/sound_controls.dart';
import '../widgets/terra_view.dart';

class _Line {
  final String text;
  final String expr;
  const _Line(this.text, this.expr);
}

class _Choice {
  final String label;
  final bool main;
  final VoidCallback onTap;
  const _Choice(this.label, this.onTap, {this.main = false});
}

/// Beranda: Terra menyapa dan memandu. Boleh dilewati kapan saja.
class HomeScreen extends StatefulWidget {
  final AppState state;
  final double bottomInset;
  final VoidCallback onOpenBoard;
  final VoidCallback onOpenProfile;
  final VoidCallback onRegister;
  final VoidCallback onPost;
  const HomeScreen({
    super.key,
    required this.state,
    required this.bottomInset,
    required this.onOpenBoard,
    required this.onOpenProfile,
    required this.onRegister,
    required this.onPost,
  });

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _sway;
  Timer? _typer;
  List<_Line> _lines = const [];
  List<_Choice> _choices = const [];
  int _i = 0;
  String _shown = '';
  bool _typing = false;
  bool _showChoices = false;
  bool _started = false;

  AppState get s => widget.state;

  @override
  void initState() {
    super.initState();
    _sway = AnimationController(vsync: this, duration: const Duration(milliseconds: 5500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _typer?.cancel();
    _sway.dispose();
    super.dispose();
  }

  /// Dipanggil setelah pintu terbuka, dan tiap kali kembali ke beranda.
  void start({required bool first}) {
    _started = true;
    if (!s.registered) {
      final lines = first
          ? const [
              _Line('Selamat datang di Guild Petualang.', 'happy'),
              _Line('Aku Terra, resepsionis di sini. Warga memasang permintaan di papan guild, dan para petualang mengambilnya.', 'smile'),
              _Line('Setiap permintaan dibayar di muka. Uangnya ditahan guild sampai pekerjaan selesai, jadi kedua pihak sama-sama aman.', 'calm'),
              _Line('Siapa pun boleh mulai dari Rank F. Mau jadi petualang?', 'smile'),
            ]
          : const [_Line('Kembali lagi? Kalau sudah siap, aku bisa mendaftarkanmu jadi petualang.', 'smile')];
      _play(lines, [
        _Choice('Ya, daftarkan aku', widget.onRegister, main: true),
        _Choice('Lihat papan quest dulu', widget.onOpenBoard),
        _Choice('Aku mau memasang permintaan', widget.onPost),
      ]);
    } else {
      final greet = s.taken.isEmpty
          ? 'Selamat datang kembali, ${s.name}! Ada banyak permintaan baru hari ini.'
          : 'Selamat datang kembali, ${s.name}! Semoga quest yang sedang kamu kerjakan lancar.';
      _play([_Line(greet, 'happy')], [
        _Choice('Buka papan quest', widget.onOpenBoard, main: true),
        _Choice('Aku mau memasang permintaan', widget.onPost),
        _Choice('Lihat profilku', widget.onOpenProfile),
      ]);
    }
  }

  /// Dipakai setelah mendaftar dari beranda.
  void welcomeNewAdventurer() {
    _play([
      _Line('Selamat bergabung, ${s.name}! Kamu resmi jadi Petualang Rank F.', 'happy'),
      const _Line('Semua orang mulai dari sini. Lihat papan quest, banyak yang bisa langsung kamu ambil.', 'smile'),
    ], [
      _Choice('Buka papan quest', widget.onOpenBoard, main: true),
      _Choice('Lihat profilku', widget.onOpenProfile),
    ]);
  }

  void _play(List<_Line> lines, List<_Choice> choices) {
    setState(() {
      _lines = lines;
      _choices = choices;
      _i = 0;
      _showChoices = false;
    });
    _type();
  }

  void _type() {
    _typer?.cancel();
    final text = _lines[_i].text;
    final instant = MediaQuery.of(context).disableAnimations;
    setState(() {
      _typing = !instant;
      _shown = instant ? text : '';
    });
    if (instant) {
      _afterLine();
      return;
    }
    var n = 0;
    _typer = Timer.periodic(const Duration(milliseconds: 20), (t) {
      n++;
      if (!mounted) return t.cancel();
      setState(() => _shown = text.substring(0, math.min(n, text.length)));
      if (n >= text.length) {
        t.cancel();
        setState(() => _typing = false);
        _afterLine();
      }
    });
  }

  void _afterLine() {
    if (_i >= _lines.length - 1) setState(() => _showChoices = true);
  }

  void _tap() {
    if (_lines.isEmpty) return;
    if (_typing) {
      _typer?.cancel();
      setState(() {
        _shown = _lines[_i].text;
        _typing = false;
      });
      _afterLine();
      return;
    }
    if (_i < _lines.length - 1) {
      _i++;
      _type();
    }
  }

  void _skip() {
    if (_lines.isEmpty) return;
    _typer?.cancel();
    setState(() {
      _i = _lines.length - 1;
      _shown = _lines[_i].text;
      _typing = false;
      _showChoices = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return LayoutBuilder(builder: (context, box) {
      final counterH = (box.maxHeight * 0.36).clamp(250.0, 320.0);
      final expr = _lines.isEmpty ? 'happy' : _lines[_i].expr;
      return ColoredBox(
        color: const Color(0xFF0C1822),
        child: Stack(clipBehavior: Clip.none, children: [
          // dinding
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0B1721), Color(0xFF102230), Color(0xFF0A141D)], stops: [0, 0.58, 1]),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(center: const Alignment(0, -0.45), radius: 0.9, colors: [C.lantern.withValues(alpha: 0.2), Colors.transparent]),
              ),
            ),
          ),
          Positioned(top: 38, left: 0, right: 0, child: Center(child: SvgPicture.asset('assets/scene/window.svg', width: 310, height: 372))),
          const Positioned(top: -6, left: 12, child: _Banner()),
          const Positioned(top: -6, right: 12, child: _Banner()),
          Positioned(top: 150, left: 66, child: _Lantern(_sway, 0)),
          Positioned(top: 150, right: 66, child: _Lantern(_sway, 0.5)),
          // Terra
          Positioned(
            left: 36,
            right: 36,
            top: 46,
            bottom: counterH - 38,
            child: TerraView(gender: s.gender, expression: expr, talking: _typing),
          ),
          // meja
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: counterH,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF16293A), Color(0xFF0C1823)]),
                border: Border(top: BorderSide(color: C.lanternLo, width: 2)),
                boxShadow: [BoxShadow(color: Color(0xB3000000), blurRadius: 36, offset: Offset(0, -16), spreadRadius: -10)],
              ),
            ),
          ),
          Positioned(left: 22, bottom: counterH - 1, child: SvgPicture.asset('assets/scene/ledger.svg', width: 78)),
          Positioned(right: 26, bottom: counterH - 1, child: SvgPicture.asset('assets/scene/bell.svg', width: 42)),
          // pilihan wujud Terra
          Positioned(
            top: mq.padding.top + 14,
            right: 14,
            child: Row(mainAxisSize: MainAxisSize.min, children: [const SoundButton(), const SizedBox(width: 8), _GenderToggle(state: s)]),
          ),
          // dialog
          Positioned(
            left: 14,
            right: 14,
            bottom: 12 + 64 + 14 + widget.bottomInset,
            child: _started ? _dialogue() : const SizedBox.shrink(),
          ),
        ]),
      );
    });
  }

  Widget _dialogue() {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Stack(clipBehavior: Clip.none, children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CutCard(
            fill: const Color(0xFF0C1822),
            edge: C.lantern.withValues(alpha: 0.7),
            padding: EdgeInsets.zero,
            onTap: _tap,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 94),
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
              child: Stack(children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Semantics(liveRegion: true, child: Text(_shown, style: body(15, height: 1.55))),
                ),
                if (!_typing && !_showChoices)
                  const Positioned(right: 0, bottom: -6, child: _NextDiamond()),
              ]),
            ),
          ),
        ),
        Positioned(
          left: 12,
          top: 0,
          child: ClipPath(
            clipper: _PlateClipper(),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 4, 18, 5),
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF8CF7E), Color(0xFFE0982B)])),
              child: Text('TERRA', style: display(13, color: const Color(0xFF2A1A00), spacing: 1.4)),
            ),
          ),
        ),
        Positioned(
          right: 10,
          top: 14,
          child: Semantics(
            button: true,
            label: 'Lewati dialog',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _skip,
              child: Padding(padding: const EdgeInsets.all(6), child: Text('Lewati ›', style: body(11.5, color: C.mist3, weight: FontWeight.w700))),
            ),
          ),
        ),
      ]),
      if (_showChoices)
        for (final c in _choices)
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: CutCard(
              cut: 9,
              fill: c.main ? const Color(0xFF2A2412) : const Color(0xFF15293A),
              edge: c.main ? C.lantern : C.line,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              onTap: c.onTap,
              child: Row(children: [
                Transform.rotate(angle: math.pi / 4, child: Container(width: 8, height: 8, color: C.lantern)),
                const SizedBox(width: 12),
                Expanded(child: Text(c.label, style: body(14, weight: FontWeight.w600))),
              ]),
            ),
          ),
    ]);
  }
}

class _PlateClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..moveTo(7, 0)
    ..lineTo(s.width, 0)
    ..lineTo(s.width - 7, s.height)
    ..lineTo(0, s.height)
    ..close();
  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

class _NextDiamond extends StatefulWidget {
  const _NextDiamond();
  @override
  State<_NextDiamond> createState() => _NextDiamondState();
}

class _NextDiamondState extends State<_NextDiamond> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, _) => Transform.translate(
          offset: Offset(0, 3 * _c.value),
          child: Transform.rotate(angle: math.pi / 4, child: Container(width: 10, height: 10, color: C.lantern)),
        ),
      );
}

class _Banner extends StatelessWidget {
  const _Banner();
  @override
  Widget build(BuildContext context) => ClipPath(
        clipper: _BannerClipper(),
        child: Container(
          width: 46,
          height: 176,
          padding: const EdgeInsets.only(top: 34),
          decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1B5A5E), Color(0xFF12393F)])),
          alignment: Alignment.topCenter,
          child: SvgPicture.asset('assets/scene/crest.svg', width: 30, height: 30),
        ),
      );
}

class _BannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..lineTo(s.width, 0)
    ..lineTo(s.width, s.height)
    ..lineTo(s.width / 2, s.height * 0.88)
    ..lineTo(0, s.height)
    ..close();
  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

class _Lantern extends StatelessWidget {
  final Animation<double> anim;
  final double phase;
  const _Lantern(this.anim, this.phase);
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: anim,
        builder: (_, _) {
          final v = (anim.value + phase) % 1.0;
          final angle = (v < 0.5 ? v : 1 - v) * 2 * 0.09 - 0.045;
          return Transform.rotate(
            angle: angle,
            alignment: const Alignment(0, -2.6),
            child: Column(children: [
              Container(width: 2, height: 26, color: const Color(0xFF5A4A2A)),
              Container(
                width: 18,
                height: 26,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5), bottomLeft: Radius.circular(9), bottomRight: Radius.circular(9)),
                  gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFE7B0), Color(0xFFF0B14A)]),
                  boxShadow: [
                    BoxShadow(color: C.lantern.withValues(alpha: 0.38), blurRadius: 28, spreadRadius: 6),
                    BoxShadow(color: C.lantern.withValues(alpha: 0.16), blurRadius: 70, spreadRadius: 18),
                  ],
                ),
              ),
            ]),
          );
        },
      );
}

class _GenderToggle extends StatelessWidget {
  final AppState state;
  const _GenderToggle({required this.state});
  @override
  Widget build(BuildContext context) {
    Widget opt(String label, String g) {
      final on = state.gender == g;
      return Semantics(
        button: true,
        selected: on,
        label: 'Terra $label',
        child: GestureDetector(
          onTap: () => state.setGender(g),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(color: on ? C.lantern : Colors.transparent, borderRadius: BorderRadius.circular(99)),
            child: Text(label, style: body(11.5, color: on ? const Color(0xFF2A1A00) : C.mist2, weight: FontWeight.w600)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: const Color(0xCC0A141D), borderRadius: BorderRadius.circular(99), border: Border.all(color: C.line)),
      child: ListenableBuilder(
        listenable: state,
        builder: (_, _) => Row(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.fromLTRB(10, 0, 6, 0), child: Text('TERRA', style: display(11, color: C.lantern, spacing: 0.9))),
          opt('Perempuan', 'f'),
          opt('Laki-laki', 'm'),
        ]),
      ),
    );
  }
}
