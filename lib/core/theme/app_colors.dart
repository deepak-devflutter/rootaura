import 'package:flutter/material.dart';

/// Raw brand swatches — "Editorial Organic Luxury" palette:
/// deep forest green + warm stone/cream neutrals + refined gold accent.
/// Semantic, theme-aware tokens live in [BrandColors].
class AppColors {
  AppColors._();

  // Brand greens
  static const Color primaryGreen = Color(0xFF1E6F43);
  static const Color darkGreen = Color(0xFF123D2A);
  static const Color midGreen = Color(0xFF2E8B57);
  static const Color softGreen = Color(0xFF7BAE95);
  static const Color mintTint = Color(0xFFEDF3EE);

  // Accents — refined gold (luxury), warm berry for sale/destructive
  static const Color gold = Color(0xFFB0852F);
  static const Color goldSoft = Color(0xFFEADFC6);
  static const Color berry = Color(0xFFC0444D);
  static const Color mango = Color(0xFFF5A623);

  // Neutrals (light) — warm stone & cream
  static const Color cream = Color(0xFFFBF9F4);
  static const Color background = Color(0xFFFAF8F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF4F0E8);
  static const Color textPrimary = Color(0xFF1C1A17); // warm near-black
  static const Color textSecondary = Color(0xFF5B554C); // warm stone
  static const Color border = Color(0xFFE9E3D7);

  // Neutrals (dark) — warm charcoal
  static const Color backgroundDark = Color(0xFF12110F);
  static const Color surfaceDark = Color(0xFF1A1815);
  static const Color surfaceAltDark = Color(0xFF221F1A);
  static const Color textPrimaryDark = Color(0xFFF2EEE6);
  static const Color textSecondaryDark = Color(0xFFA8A095);
  static const Color borderDark = Color(0xFF2C2823);
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
  // Surface ladder + warmth (kills the flat white-on-white look)
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color translucentSurface; // for the one glass header
  final Color forestTintOverlay; // warm green wash for alt section bands

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
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.translucentSurface,
    required this.forestTintOverlay,
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
    // Warm, soft, layered shadow — the "expensive" depth.
    shadow: Color(0x14241B0A),
    surfaceRaised: AppColors.surface,
    surfaceSunken: AppColors.surfaceAlt,
    translucentSurface: Color(0xCCFBF9F4),
    forestTintOverlay: Color(0x0D1E6F43), // primaryGreen @ ~5%
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
    shadow: Color(0x55000000),
    surfaceRaised: Color(0xFF221F1A),
    surfaceSunken: AppColors.backgroundDark,
    translucentSurface: Color(0xCC1A1815),
    forestTintOverlay: Color(0x1A1E6F43),
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
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? translucentSurface,
    Color? forestTintOverlay,
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
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      translucentSurface: translucentSurface ?? this.translucentSurface,
      forestTintOverlay: forestTintOverlay ?? this.forestTintOverlay,
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
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      translucentSurface:
          Color.lerp(translucentSurface, other.translucentSurface, t)!,
      forestTintOverlay:
          Color.lerp(forestTintOverlay, other.forestTintOverlay, t)!,
    );
  }
}

/// Convenience accessor: `context.brand.accent`.
extension BrandColorsX on BuildContext {
  BrandColors get brand =>
      Theme.of(this).extension<BrandColors>() ?? BrandColors.light;
}
