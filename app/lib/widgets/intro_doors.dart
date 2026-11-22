import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme.dart';

/// Pintu guild yang membuka ke ruang resepsionis (±2,6 detik).
class IntroDoors extends StatefulWidget {
  final VoidCallback onOpened;
  const IntroDoors({super.key, required this.onOpened});

  @override
  State<IntroDoors> createState() => _IntroDoorsState();
}

class _IntroDoorsState extends State<IntroDoors> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2700));
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) _finish();
    });
    _c.forward();
  }

  void _finish() {
    if (_done) return;
    _done = true;
    widget.onOpened();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finish());
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // 0 - 0.18 menunggu, lalu pintu membuka
        final t = ((_c.value - 0.18) / 0.82).clamp(0.0, 1.0);
        final open = Curves.easeInOutCubic.transform(t);
        final angle = open * math.pi * 0.54;
        final flare = math.sin(t * math.pi).clamp(0.0, 1.0);
        return Stack(fit: StackFit.expand, children: [
          IgnorePointer(
            child: Opacity(
              opacity: flare * 0.9,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(radius: 0.8, colors: [Color(0xFFFFE9BD), Color(0xFFF0B14A), Color(0x00F0B14A)], stops: [0, 0.35, 1]),
                ),
              ),
            ),
          ),
          Row(children: [
            Expanded(child: _Leaf(left: true, angle: -angle)),
            Expanded(child: _Leaf(left: false, angle: angle)),
          ]),
          Positioned(
            right: 16,
            bottom: 18 + MediaQuery.of(context).padding.bottom,
            child: Semantics(
              button: true,
              label: 'Lewati pembuka',
              child: GestureDetector(
                onTap: _finish,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0A141D),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: C.line),
                  ),
                  child: Text('Lewati ›', style: body(12, color: C.mist2, weight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }
}

class _Leaf extends StatelessWidget {
  final bool left;
  final double angle;
  const _Leaf({required this.left, required this.angle});

  @override
  Widget build(BuildContext context) {
    final visible = angle.abs() < math.pi * 0.5;
    return Transform(
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateY(angle),
      child: visible
          ? ClipRect(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF143846), Color(0xFF0F2A36), Color(0xFF0A1D27)], stops: [0, 0.6, 1]),
                ),
                child: Stack(clipBehavior: Clip.hardEdge, children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent, Colors.transparent, Colors.black.withValues(alpha: 0.4)],
                          stops: const [0, 0.14, 0.86, 1],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 28,
                    bottom: 120,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: C.lantern.withValues(alpha: 0.42)),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(left ? 170 : 0), topRight: Radius.circular(left ? 0 : 170)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: left ? null : -96,
                    right: left ? -96 : null,
                    top: 0,
                    bottom: 0,
                    child: Center(child: SvgPicture.asset('assets/scene/crest.svg', width: 192, height: 192)),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 72,
                    child: Container(height: 16, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF5B4116), Color(0xFF3A2A0C)]))),
                  ),
                ]),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
