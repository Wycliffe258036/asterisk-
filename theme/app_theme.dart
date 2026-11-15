import 'package:flutter/material.dart';

/// Shared, restrained Material 3 themes for the entire Asterisk app.
class AppTheme {
  AppTheme._();

  static const Color _lightBackground = Color(0xFFF7F7F5);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightText = Color(0xFF202124);
  static const Color _lightMuted = Color(0xFF6B7280);
  static const Color _lightBorder = Color(0xFFE6E7E8);

  static const Color _darkBackground = Color(0xFF17191D);
  static const Color _darkSurface = Color(0xFF22252A);
  static const Color _darkText = Color(0xFFF1F2F3);
  static const Color _darkMuted = Color(0xFFA2A7AF);
  static const Color _darkBorder = Color(0xFF343941);

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: Color(0xFF46515D),
      onPrimary: Colors.white,
      secondary: Color(0xFF687583),
      onSecondary: Colors.white,
      surface: _lightSurface,
      onSurface: _lightText,
      error: Color(0xFFB42318),
      outline: _lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: _lightSurface,
      dividerColor: _lightBorder,
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: _lightText,
        displayColor: _lightText,
      ),
      iconTheme: const IconThemeData(color: _lightMuted),
      dividerTheme: const DividerThemeData(
        color: _lightBorder,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightText,
          side: const BorderSide(color: _lightBorder),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF30343A),
        contentTextStyle: ThemeData.dark().textTheme.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: Color(0xFFC5CDD5),
      onPrimary: Color(0xFF20252B),
      secondary: Color(0xFFAAB5C0),
      onSecondary: Color(0xFF20252B),
      surface: _darkSurface,
      onSurface: _darkText,
      error: Color(0xFFFFB4AB),
      outline: _darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: _darkSurface,
      dividerColor: _darkBorder,
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: _darkText,
        displayColor: _darkText,
      ),
      iconTheme: const IconThemeData(color: _darkMuted),
      dividerTheme: const DividerThemeData(
        color: _darkBorder,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkText,
          side: const BorderSide(color: _darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFE6E8EB),
        contentTextStyle: ThemeData.light().textTheme.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
