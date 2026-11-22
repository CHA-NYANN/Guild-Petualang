import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warna "guildhall di senja": biru pelabuhan, emas lentera, hijau giok, merah bara.
class C {
  static const night = Color(0xFF070D12);
  static const ink900 = Color(0xFF0E1A24);
  static const ink800 = Color(0xFF142431);
  static const ink700 = Color(0xFF1C3243);
  static const line = Color(0xFF28425A);
  static const lineSoft = Color(0xFF1D3345);
  static const mist = Color(0xFFE8EEF2);
  static const mist2 = Color(0xFFA9BBC7);
  static const mist3 = Color(0xFF7B909F);
  static const lantern = Color(0xFFF0B14A);
  static const lanternHi = Color(0xFFF8CF7E);
  static const lanternLo = Color(0xFFC98A21);
  static const jade = Color(0xFF56C3A8);
  static const ember = Color(0xFFEA6A57);
  static const sky = Color(0xFF8FB0FF);
}

/// Dimatikan di pengujian agar tidak mengunduh font.
class Fonts {
  static bool useWebFonts = true;
}

TextStyle display(double size, {Color color = C.mist, FontWeight weight = FontWeight.w700, double spacing = 0.6}) {
  final base = Fonts.useWebFonts
      ? GoogleFonts.cinzel(fontSize: size, color: color, fontWeight: weight, letterSpacing: spacing)
      : TextStyle(fontSize: size, color: color, fontWeight: weight, letterSpacing: spacing);
  return base;
}

TextStyle body(double size, {Color color = C.mist, FontWeight weight = FontWeight.w500, double? height, double spacing = 0}) {
  return Fonts.useWebFonts
      ? GoogleFonts.plusJakartaSans(fontSize: size, color: color, fontWeight: weight, height: height, letterSpacing: spacing)
      : TextStyle(fontSize: size, color: color, fontWeight: weight, height: height, letterSpacing: spacing);
}

ThemeData buildTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: C.ink900,
    colorScheme: const ColorScheme.dark(primary: C.lantern, surface: C.ink900),
    splashFactory: NoSplash.splashFactory,
    useMaterial3: true,
  );
}

String rp(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp$buf';
}
