import 'package:flutter/material.dart';

import 'app_state.dart';
import 'audio.dart';
import 'screens/board_screen.dart';
import 'screens/home_screen.dart';
import 'screens/post_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/sheets.dart';
import 'theme.dart';
import 'widgets/common.dart';
import 'widgets/intro_doors.dart';

class GuildApp extends StatelessWidget {
  final bool showIntro;

  /// Tanpa ini aplikasi senyap (dipakai di pengujian). main.dart memberikan pemutar sungguhan.
  final AudioService? audio;
  const GuildApp({super.key, this.showIntro = true, this.audio});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Guild Petualang',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      builder: (context, child) => ColoredBox(
        color: C.night,
        child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430), child: child)),
      ),
      home: AppShell(showIntro: showIntro, audio: audio ?? SilentAudio()),
    );
  }
}

class AppShell extends StatefulWidget {
  final bool showIntro;
  final AudioService audio;
  const AppShell({super.key, required this.showIntro, required this.audio});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  final AppState state = AppState();
  final GlobalKey<HomeScreenState> _home = GlobalKey();
  late bool _intro = widget.showIntro;
  AudioService get _audio => widget.audio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AudioService.current = _audio;
    if (_intro) {
      _audio.sfx(Sfx.door);
    } else {
      _audio.startMusic();
      WidgetsBinding.instance.addPostFrameCallback((_) => _home.currentState?.start(first: true));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed) {
      _audio.resume();
    } else {
      _audio.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    state.dispose();
    super.dispose();
  }

  void _toast(String m) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(m, style: body(13, weight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1D3A4F),
        margin: EdgeInsets.fromLTRB(16, 0, 16, 96 + MediaQuery.of(context).padding.bottom),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: C.lanternLo)),
      ));
  }

  Future<void> _register({required bool fromHome}) async {
    final ok = await showRegisterSheet(context, state);
    if (!ok || !mounted) return;
    if (fromHome) {
      state.goTo(0);
      _home.currentState?.welcomeNewAdventurer();
    } else {
      _toast('Kamu resmi jadi Petualang Rank F.');
    }
  }

  void _openPost() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PostQuestScreen(state: state)));

  void _selectTab(int i) {
    if (i != state.navIndex) _audio.sfx(Sfx.tap);
    state.goTo(i);
    if (i == 0) _home.currentState?.start(first: false);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: ListenableBuilder(
        listenable: state,
        // Ketukan pertama membuka kunci suara di browser, yang menolak suara otomatis.
        builder: (context, _) => Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            if (!_intro) _audio.startMusic();
          },
          child: Stack(children: [
          Positioned.fill(
            child: IndexedStack(index: state.navIndex, children: [
              HomeScreen(
                key: _home,
                state: state,
                bottomInset: bottom,
                onOpenBoard: () => _selectTab(1),
                onOpenProfile: () => _selectTab(2),
                onRegister: () => _register(fromHome: true),
                onPost: _openPost,
              ),
              BoardScreen(state: state),
              ProfileScreen(state: state, onRegister: () => _register(fromHome: false)),
            ]),
          ),
          if (!_intro) Positioned(left: 14, right: 14, bottom: 14 + bottom, child: _Dock(index: state.navIndex, onTap: _selectTab)),
          if (_intro)
            Positioned.fill(
              child: IntroDoors(onOpened: () {
                setState(() => _intro = false);
                _audio.startMusic();
                WidgetsBinding.instance.addPostFrameCallback((_) => _home.currentState?.start(first: true));
              }),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Dock extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _Dock({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [('home', 'Beranda'), ('board', 'Papan'), ('prof', 'Profil')];
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xEB09121A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: C.line),
        boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 30, offset: Offset(0, 10), spreadRadius: -8)],
      ),
      child: Row(children: [
        for (var i = 0; i < items.length; i++)
          Expanded(
            child: Semantics(
              button: true,
              selected: index == i,
              label: items[i].$2,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
                  if (index == i)
                    Positioned(
                      top: -4,
                      child: Transform.rotate(
                        angle: 0.785398,
                        child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: C.lantern, boxShadow: [BoxShadow(color: C.lantern, blurRadius: 14)])),
                      ),
                    ),
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    AppIcon(items[i].$1, color: index == i ? C.lanternHi : C.mist3, size: 23),
                    const SizedBox(height: 3),
                    Text(items[i].$2, style: body(11, color: index == i ? C.lanternHi : C.mist3, weight: FontWeight.w700, spacing: 0.3)),
                  ]),
                ]),
              ),
            ),
          ),
      ]),
    );
  }
}
