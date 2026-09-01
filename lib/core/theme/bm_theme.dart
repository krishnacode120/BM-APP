import 'package:flutter/material.dart';

abstract final class BmColors {
  static const orange = Color(0xFFF57C00);
  static const ink = Color(0xFF1C1B1F);
  static const canvas = Color(0xFFFFFBFF);
  static const muted = Color(0xFF6D6A72);
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
      appBarTheme: const AppBarTheme(backgroundColor: BmColors.canvas),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
