import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color mainColor = Color(0xFF1976D2);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color secondary = Color(0xFF424242);
  static const Color accent = Color(0xFF82B1FF);
  static const Color error = Color(0xFFD32F2F);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color chipBg = Color(0x141976D2);
}

extension ColorAlphaExtension on Color {
  Color percentAlpha(int percent) {
    final int alphaValue = (255 * (percent / 100)).round();
    return withAlpha(alphaValue);
  }
}
