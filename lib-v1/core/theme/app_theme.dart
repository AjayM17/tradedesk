import 'package:flutter/material.dart';

class AppTheme {
  // ======================
  // Design Tokens
  // ======================

  static const double radius = 10.0; // 0.625rem ≈ 10px

  // Light colors (from Figma)
  static const Color background = Color(0xFFF5F6FA);
  static const Color foreground = Color(0xFF0F172A);
  static const Color card = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFECECF0);
  static const Color mutedForeground = Color(0xFF717182);
  static const Color primary = Color(0xFF030213);
  static const Color border = Color.fromRGBO(0, 0, 0, 0.1);

  // Semantic colors
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFD4183D);

  // Dark colors (approx from OKLCH)
  static const Color darkBackground = Color(0xFF18181B);
  static const Color darkForeground = Color(0xFFF4F4F5);
  static const Color darkCard = Color(0xFF18181B);

  // ======================
  // Text Theme
  // ======================

  static const TextTheme textTheme = TextTheme(
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: foreground,
      height: 1.5,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: foreground,
      height: 1.5,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: foreground,
      height: 1.5,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: mutedForeground,
    ),
  );

  // ======================
  // Light Theme
  // ======================

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',

      scaffoldBackgroundColor: background,

      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        surface: card,
        onSurface: foreground,
        error: danger,
      ),

      textTheme: textTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: muted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: primary),
        ),
      ),
    );
  }

  // ======================
  // Dark Theme
  // ======================

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',

      scaffoldBackgroundColor: darkBackground,

      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        surface: darkCard,
        onSurface: darkForeground,
        error: danger,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkForeground,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Colors.white24,
        thickness: 1,
      ),
    );
  }
}
