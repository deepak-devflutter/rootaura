import 'package:flutter/material.dart';

/// Raw brand swatches. Semantic, theme-aware tokens live in [BrandColors].
class AppColors {
  AppColors._();

  // Brand greens
  static const Color primaryGreen = Color(0xFF1E6F43);
  static const Color darkGreen = Color(0xFF0F3D2E);
  static const Color midGreen = Color(0xFF2E8B57);
  static const Color softGreen = Color(0xFF6FAF8E);
  static const Color mintTint = Color(0xFFEAF4EE);

  // Accents
  static const Color gold = Color(0xFFE8B04A);
  static const Color goldSoft = Color(0xFFF6E3B8);
  static const Color berry = Color(0xFFD64550);
  static const Color mango = Color(0xFFF5A623);

  // Neutrals (light)
  static const Color cream = Color(0xFFFBFAF5);
  static const Color background = Color(0xFFF9FBF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F6F1);
  static const Color textPrimary = Color(0xFF18241D);
  static const Color textSecondary = Color(0xFF5E6B62);
  static const Color border = Color(0xFFE4ECE6);

  // Neutrals (dark)
  static const Color backgroundDark = Color(0xFF0E1411);
  static const Color surfaceDark = Color(0xFF161D19);
  static const Color surfaceAltDark = Color(0xFF1C2621);
  static const Color textPrimaryDark = Color(0xFFEAF1EC);
  static const Color textSecondaryDark = Color(0xFF9FB0A6);
  static const Color borderDark = Color(0xFF263129);
}

/// Theme extension carrying brand-specific colours that shift between
/// light and dark mode. Access via `Theme.of(context).extension<BrandColors>()`
/// or the `context.brand` helper.
@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  final Color heroStart;
  final Color heroEnd;
  final Color sectionAlt;
  final Color card;
  final Color cardSoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color accent;
  final Color onAccentSurface; // soft accent background
  final Color shadow;

  const BrandColors({
    required this.heroStart,
    required this.heroEnd,
    required this.sectionAlt,
    required this.card,
    required this.cardSoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.accent,
    required this.onAccentSurface,
    required this.shadow,
  });

  static const light = BrandColors(
    heroStart: AppColors.cream,
    heroEnd: AppColors.mintTint,
    sectionAlt: AppColors.surfaceAlt,
    card: AppColors.surface,
    cardSoft: AppColors.surfaceAlt,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    border: AppColors.border,
    accent: AppColors.gold,
    onAccentSurface: AppColors.mintTint,
    shadow: Color(0x141E6F43),
  );

  static const dark = BrandColors(
    heroStart: AppColors.backgroundDark,
    heroEnd: AppColors.surfaceDark,
    sectionAlt: AppColors.surfaceAltDark,
    card: AppColors.surfaceDark,
    cardSoft: AppColors.surfaceAltDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
    border: AppColors.borderDark,
    accent: AppColors.gold,
    onAccentSurface: AppColors.surfaceAltDark,
    shadow: Color(0x40000000),
  );

  @override
  BrandColors copyWith({
    Color? heroStart,
    Color? heroEnd,
    Color? sectionAlt,
    Color? card,
    Color? cardSoft,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? accent,
    Color? onAccentSurface,
    Color? shadow,
  }) {
    return BrandColors(
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
      sectionAlt: sectionAlt ?? this.sectionAlt,
      card: card ?? this.card,
      cardSoft: cardSoft ?? this.cardSoft,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      onAccentSurface: onAccentSurface ?? this.onAccentSurface,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
      sectionAlt: Color.lerp(sectionAlt, other.sectionAlt, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardSoft: Color.lerp(cardSoft, other.cardSoft, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccentSurface: Color.lerp(onAccentSurface, other.onAccentSurface, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

/// Convenience accessor: `context.brand.accent`.
extension BrandColorsX on BuildContext {
  BrandColors get brand =>
      Theme.of(this).extension<BrandColors>() ?? BrandColors.light;
}
