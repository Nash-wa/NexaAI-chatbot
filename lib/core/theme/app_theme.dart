import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6E54FF);
  static const Color secondary = Color(0xFF00D8B3);
  static const Color surface = Color(0xFF121622);
  static const Color surfaceVariant = Color(0xFF1F2738);
  static const Color background = Color(0xFF090B14);
  static const Color onSurface = Color(0xFFE7E7FF);
  static const Color userBubble = Color(0xFF3C6FFF);
  static const Color assistantBubble = Color(0xFF222738);
}

class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black87,
      error: Colors.redAccent,
      onError: Colors.white,
      primaryContainer: const Color(0xFFEDE6FF),
      onPrimaryContainer: AppColors.primary,
      secondaryContainer: const Color(0xFFCBF7EA),
      onSecondaryContainer: Colors.black,
      surfaceContainerHighest: const Color(0xFFE8E8F5),
      onSurfaceVariant: const Color(0xFF444659),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F7FF),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF1F3FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide.none,
      ),
    ),
    textTheme: Typography.blackMountainView,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        elevation: 0,
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.black,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      error: Colors.redAccent,
      onError: Colors.white,
      primaryContainer: const Color(0xFF392F7C),
      onPrimaryContainer: Colors.white,
      secondaryContainer: const Color(0xFF004D3F),
      onSecondaryContainer: Colors.white,
      surfaceContainerHighest: AppColors.surfaceVariant,
      onSurfaceVariant: Colors.white70,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.surface,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF192035),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide.none,
      ),
    ),
    textTheme: Typography.whiteMountainView,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        elevation: 0,
      ),
    ),
  );
}
