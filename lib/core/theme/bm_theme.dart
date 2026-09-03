import 'package:flutter/material.dart';

abstract final class BmColors {
  static const orange = Color(0xFFFF6B1A);
  static const strongOrange = Color(0xFFFF6500);
  static const lightOrange = Color(0xFFFFF0E5);
  static const peach = Color(0xFFFFF7F2);
  static const ink = Color(0xFF161616);
  static const canvas = Color(0xFFFFFCFA);
  static const secondaryText = Color(0xFF6F6F6F);
  static const border = Color(0xFFECECEC);
  static const success = Color(0xFF2E9B50);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFE5484D);
}

abstract final class BmTheme {
  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: BmColors.orange,
      brightness: Brightness.light,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: BmColors.canvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: BmColors.canvas,
        foregroundColor: BmColors.ink,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: .06),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: BmColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BmColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BmColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: BmColors.orange, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BmColors.strongOrange,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BmColors.orange,
          minimumSize: const Size(48, 50),
          side: const BorderSide(color: BmColors.orange),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        indicatorColor: BmColors.lightOrange,
        backgroundColor: Colors.white,
        labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ),
      dividerColor: BmColors.border,
      textTheme: const TextTheme(
        headlineMedium:
            TextStyle(fontWeight: FontWeight.w800, color: BmColors.ink),
        headlineSmall:
            TextStyle(fontWeight: FontWeight.w800, color: BmColors.ink),
        titleLarge: TextStyle(fontWeight: FontWeight.w800, color: BmColors.ink),
        titleMedium:
            TextStyle(fontWeight: FontWeight.w700, color: BmColors.ink),
        bodyMedium: TextStyle(color: BmColors.secondaryText, height: 1.45),
      ),
    );
  }
}
