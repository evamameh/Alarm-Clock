import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFFF7F7);
  static const surface = Color(0xFFFFFEFE);
  static const blush = Color(0xFFFFDDE5);
  static const blushStrong = Color(0xFFFF9EB5);
  static const rose = Color(0xFF935064);
  static const roseDark = Color(0xFF5A2538);
  static const ink = Color(0xFF231B20);
  static const muted = Color(0xFF9C9297);
  static const border = Color(0xFFF2DDE1);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Arial',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.rose,
        brightness: Brightness.light,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.roseDark,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.rose,
          fontSize: 70,
          fontWeight: FontWeight.w800,
          height: 0.95,
        ),
      ),
    );
  }
}
