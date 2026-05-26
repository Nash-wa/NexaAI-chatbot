import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF6C63FF);       // Nebula Indigo
  static const Color secondary = Color(0xFF00E5FF);     // Holographic Cyan
  static const Color accent = Color(0xFFA855F7);        // Aurora Purple
  static const Color surface = Color(0xFF0F172A);       // Translucent Slate Card Base
  static const Color surfaceVariant = Color(0xFF1E293B); // Darker Blue Slate
  static const Color background = Color(0xFF050816);     // Deep Space Cosmic Dark
  static const Color onSurface = Color(0xFFE2E8F0);      // High-contrast slate white
  static const Color userBubble = Color(0xFF6C63FF);
  static const Color assistantBubble = Color(0x14FFFFFF); // Translucent card glass
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
