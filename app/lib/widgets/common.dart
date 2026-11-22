import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../audio.dart';
import '../theme.dart';

const _rankColors = {
  'F': [Color(0xFFB4C0C9), Color(0xFF66747F)],
  'E': [Color(0xFFE6A872), Color(0xFF8F572B)],
  'D': [Color(0xFFE4EBF0), Color(0xFF81919D)],
  'C': [Color(0xFFF8CF7E), Color(0xFFB57A14)],
  'B': [Color(0xFF82E2C9), Color(0xFF2C8570)],
  'A': [Color(0xFFA9C2FF), Color(0xFF3A56B3)],
  'S': [Color(0xFFFFA08B), Color(0xFFA8281C)],
};

String _hex(Color c) {
  int ch(double v) => (v * 255).round().clamp(0, 255);
  return '#${ch(c.r).toRadixString(16).padLeft(2, '0')}${ch(c.g).toRadixString(16).padLeft(2, '0')}${ch(c.b).toRadixString(16).padLeft(2, '0')}';
}

/// Segel rank berbentuk perisai.
class RankSeal extends StatelessWidget {
  final String rank;
  final double width;
  final double opacity;
  const RankSeal(this.rank, {super.key, this.width = 44, this.opacity = 1});

  @override
  Widget build(BuildContext context) {
    final c = _rankColors[rank]!;
    final svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 40 46">
<defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${_hex(c[0])}"/><stop offset="1" stop-color="${_hex(c[1])}"/></linearGradient></defs>
<path d="M20 1.5 37 8v16c0 10.5-8 17.5-17 21C11 41.5 3 34.5 3 24V8z" fill="url(#g)" stroke="#FFFFFF" stroke-opacity=".6" stroke-width="1"/>
<path d="M20 6 33 11v13c0 8-6 13.6-13 16.6C13 37.6 7 32 7 24V11z" fill="none" stroke="#000000" stroke-opacity=".28" stroke-width="1.2"/>
</svg>''';
    return Opacity(
      opacity: opacity,
      child: SizedBox(
        width: width,
        height: width * 1.15,
        child: Stack(alignment: Alignment.center, children: [
          SvgPicture.string(svg, width: width, height: width * 1.15),
          Padding(
            padding: EdgeInsets.only(top: width * 0.04),
            child: Text(rank, style: display(width * 0.46, color: const Color(0xFF1A1205))),
          ),
        ]),
      ),
    );
  }
}

/// Permukaan dengan sudut dipotong dan garis tepi tipis.
class CutCard extends StatelessWidget {
  final Widget child;
  final Color fill;
  final Color edge;
  final double cut;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const CutCard({
    super.key,
    required this.child,
    this.fill = C.ink800,
    this.edge = C.line,
    this.cut = 12,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = BeveledRectangleBorder(borderRadius: BorderRadius.circular(cut), side: BorderSide(color: edge));
    return Material(
      color: fill,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: C.lantern.withValues(alpha: 0.08),
        highlightColor: C.lantern.withValues(alpha: 0.05),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Tombol utama emas dengan sudut dipotong.
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool ghost;
  final IconData? icon;
  const GoldButton(this.label, {super.key, this.onTap, this.ghost = false, this.icon});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final Gradient? grad = ghost || !enabled
        ? null
        : const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFF8CF7E), Color(0xFFE7A236), Color(0xFFD58E1E)]);
    final bg = !enabled ? const Color(0xFF26394A) : (ghost ? const Color(0xFF1B3040) : null);
    final fg = !enabled ? const Color(0xFF7D93A4) : (ghost ? C.mist : const Color(0xFF2A1A00));
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: ClipPath(
        clipper: _CutClipper(12),
        child: Material(
          color: bg ?? Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(gradient: grad),
            child: InkWell(
              onTap: enabled
                  ? () {
                      AudioService.current.sfx(Sfx.tap);
                      onTap!();
                    }
                  : null,
              child: Container(
                constraints: const BoxConstraints(minHeight: 50),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (icon != null) ...[Icon(icon, size: 18, color: fg), const SizedBox(width: 8)],
                  Flexible(child: Text(label, textAlign: TextAlign.center, style: body(15, color: fg, weight: FontWeight.w800))),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CutClipper extends CustomClipper<Path> {
  final double c;
  _CutClipper(this.c);
  @override
  Path getClip(Size s) => Path()
    ..moveTo(c, 0)
    ..lineTo(s.width - c, 0)
    ..lineTo(s.width, c)
    ..lineTo(s.width, s.height - c)
    ..lineTo(s.width - c, s.height)
    ..lineTo(c, s.height)
    ..lineTo(0, s.height - c)
    ..lineTo(0, c)
    ..close();
  @override
  bool shouldReclip(covariant _CutClipper old) => old.c != c;
}

/// Bilah atas layar penuh: tombol kembali dan judul kecil di tengah.
class GuildTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  const GuildTopBar({super.key, required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        child: Row(children: [
          Semantics(
            button: true,
            label: 'Kembali',
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: const Color(0xFF15293A), borderRadius: BorderRadius.circular(12), border: Border.all(color: C.line)),
                child: const Center(child: AppIcon('back', color: C.mist, size: 20)),
              ),
            ),
          ),
          Expanded(child: Center(child: Text(title, style: body(11, color: C.mist3, weight: FontWeight.w800, spacing: 1.5)))),
          const SizedBox(width: 40),
        ]),
      );
}

/// Judul bagian berlambang belah ketupat.
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 26, bottom: 12),
        child: Row(children: [
          Transform.rotate(angle: math.pi / 4, child: Container(width: 7, height: 7, color: C.lantern)),
          const SizedBox(width: 10),
          Text(text.toUpperCase(), style: display(15, spacing: 1)),
        ]),
      );
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final Color? border;
  final Color? fill;
  final IconData? icon;
  const Pill(this.text, {super.key, this.color = C.mist2, this.border, this.fill, this.icon});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: fill ?? const Color(0xFF0B1620),
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: border ?? C.lineSoft),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 5)],
          Flexible(child: Text(text, style: body(11.5, color: color, weight: FontWeight.w600))),
        ]),
      );
}

const _iconPaths = {
  'home': '<path d="M5 21V11a7 7 0 0 1 14 0v10M9 21v-6a3 3 0 0 1 6 0v6"/>',
  'board': '<path d="M6 3h12v14l-3 4H6z"/><path d="M9 8h6M9 12h6"/>',
  'prof': '<path d="M12 3l7 3v5c0 5-3 8-7 10-4-2-7-5-7-10V6z"/><path d="M12 9l1.2 2.4 2.6.4-1.9 1.8.5 2.6L12 15l-2.4 1.2.5-2.6-1.9-1.8 2.6-.4z"/>',
  'lock': '<path d="M7 11V8a5 5 0 0 1 10 0v3"/><path d="M5 11h14v10H5z"/>',
  'clock': '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
  'pin': '<path d="M12 21s-7-6.2-7-11a7 7 0 0 1 14 0c0 4.8-7 11-7 11z"/><circle cx="12" cy="10" r="2.4"/>',
  'globe': '<circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3c3 3 3 15 0 18-3-3-3-15 0-18z"/>',
  'check': '<path d="M5 12.5l4.5 4.5L19 7.5"/>',
  'back': '<path d="M15 5l-7 7 7 7"/>',
  'bolt': '<path d="M13 3L5 13.5h6L10 21l8-10.5h-6z"/>',
  'shield': '<path d="M12 3l7 3v5c0 5-3 8-7 10-4-2-7-5-7-10V6z"/><path d="M8.8 12l2.4 2.4 4-4.4"/>',
  'warn': '<path d="M12 4l9 16H3z"/><path d="M12 10v4M12 17v.2"/>',
  'star': '<path d="M12 3.5l2.4 5 5.4.7-4 3.8 1 5.4L12 15.7l-4.8 2.7 1-5.4-4-3.8 5.4-.7z"/>',
  'info': '<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 8v.2"/>',
  'plus': '<path d="M12 5v14M5 12h14"/>',
  'sound': '<path d="M4 9v6h4l5 4V5L8 9z"/><path d="M16.5 8.5a5 5 0 0 1 0 7"/><path d="M19 6a8.5 8.5 0 0 1 0 12"/>',
  'mute': '<path d="M4 9v6h4l5 4V5L8 9z"/><path d="M17 9.5l5 5M22 9.5l-5 5"/>',
};

/// Ikon garis bergaya guild.
class AppIcon extends StatelessWidget {
  final String name;
  final Color color;
  final double size;
  const AppIcon(this.name, {super.key, this.color = C.mist2, this.size = 18});
  @override
  Widget build(BuildContext context) {
    final svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="${_hex(color)}" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">${_iconPaths[name]}</svg>';
    return SvgPicture.string(svg, width: size, height: size);
  }
}
