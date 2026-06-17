import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds the light and dark [ThemeData] for Rootaura Naturals.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        brand: BrandColors.light,
        scaffold: AppColors.background,
        scheme: const ColorScheme.light(
          primary: AppColors.primaryGreen,
          onPrimary: Colors.white,
          secondary: AppColors.gold,
          onSecondary: AppColors.darkGreen,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
        ),
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        brand: BrandColors.dark,
        scaffold: AppColors.backgroundDark,
        scheme: const ColorScheme.dark(
          primary: AppColors.softGreen,
          onPrimary: AppColors.darkGreen,
          secondary: AppColors.gold,
          onSecondary: AppColors.darkGreen,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.textPrimaryDark,
        ),
      );

  static ThemeData _build({
    required Brightness brightness,
    required BrandColors brand,
    required Color scaffold,
    required ColorScheme scheme,
  }) {
    final baseText = (brightness == Brightness.dark
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme)
        .apply(
      fontFamily: AppTextStyles.inter,
      bodyColor: brand.textPrimary,
      displayColor: brand.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: baseText,
      dividerColor: brand.border,
      extensions: [brand],
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkGreen,
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}
