import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  /// SF Pro is preferred when the font is installed/bundled.
  ///
  /// Inter provides a very close visual fallback on platforms where
  /// SF Pro is unavailable.
  static const String primaryFont = 'SF Pro Display';

  static const List<String> fallbackFonts = [
    'Inter',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  static TextStyle display({
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w700,
    Color color = const Color(0xFF111111),
  }) {
    return TextStyle(
      fontFamily: primaryFont,
      fontFamilyFallback: fallbackFonts,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.6,
    );
  }

  static TextStyle title({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w600,
    Color color = const Color(0xFF111111),
  }) {
    return TextStyle(
      fontFamily: primaryFont,
      fontFamilyFallback: fallbackFonts,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.35,
    );
  }

  static TextStyle body({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w400,
    Color color = const Color(0xFF111111),
  }) {
    return TextStyle(
      fontFamily: primaryFont,
      fontFamilyFallback: fallbackFonts,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.15,
    );
  }

  static TextStyle caption({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w400,
    Color color = const Color(0xFF666666),
  }) {
    return TextStyle(
      fontFamily: primaryFont,
      fontFamilyFallback: fallbackFonts,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.05,
    );
  }
}