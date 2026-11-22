import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Terra dengan napas pelan, kedip, dan mulut bergerak saat bicara.
class TerraView extends StatefulWidget {
  final String gender; // 'f' atau 'm'
  final String expression; // happy, smile, calm
  final bool talking;
  const TerraView({super.key, required this.gender, required this.expression, this.talking = false});

  @override
  State<TerraView> createState() => _TerraViewState();
}

class _TerraViewState extends State<TerraView> with SingleTickerProviderStateMixin {
  late final AnimationController _breath;
  Timer? _blinkTimer;
  Timer? _talkTimer;
  bool _blink = false;
  bool _mouthOpen = false;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat(reverse: true);
    _scheduleBlink();
    _syncTalk();
  }

  @override
  void didUpdateWidget(covariant TerraView old) {
    super.didUpdateWidget(old);
    if (old.talking != widget.talking) _syncTalk();
  }

  void _scheduleBlink() {
    _blinkTimer = Timer(Duration(milliseconds: 3200 + math.Random().nextInt(2600)), () {
      if (!mounted) return;
      setState(() => _blink = true);
      _blinkTimer = Timer(const Duration(milliseconds: 130), () {
        if (!mounted) return;
        setState(() => _blink = false);
        _scheduleBlink();
      });
    });
  }

  void _syncTalk() {
    _talkTimer?.cancel();
    if (widget.talking) {
      _talkTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
        if (mounted) setState(() => _mouthOpen = !_mouthOpen);
      });
    } else {
      _mouthOpen = false;
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _talkTimer?.cancel();
    _breath.dispose();
    super.dispose();
  }

  String get _asset {
    final g = widget.gender;
    if (widget.expression == 'happy') return 'assets/terra/terra_${g}_happy.svg';
    if (_blink) return 'assets/terra/terra_${g}_blink.svg';
    if (widget.talking && _mouthOpen) return 'assets/terra/terra_${g}_talk.svg';
    return 'assets/terra/terra_${g}_${widget.expression}.svg';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Terra, resepsionis guild',
      image: true,
      child: AnimatedBuilder(
        animation: _breath,
        builder: (context, child) => Transform.translate(offset: Offset(0, -3 * Curves.easeInOut.transform(_breath.value)), child: child),
        child: SvgPicture.asset(_asset, fit: BoxFit.contain, alignment: Alignment.bottomCenter, excludeFromSemantics: true),
      ),
    );
  }
}
