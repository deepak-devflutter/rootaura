import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brand gradients. Gold is always **foiled** (a 3-stop gradient that reads
/// like light catching a metallic edge) — never a flat fill.
class AppGradients {
  AppGradients._();

  /// Foiled gold for primary CTAs, the Total band, active accents.
  static const LinearGradient goldFoil = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD8B86A), Color(0xFFB0852F), Color(0xFF8A6520)],
  );

  /// Warm hero wash, cream → mint.
  static const LinearGradient heroWash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.cream, AppColors.mintTint],
  );

  /// Deep forest band (values band, pull-quotes, brand panels).
  static const LinearGradient forestBand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.darkGreen, AppColors.primaryGreen],
  );

  /// Soft radial glow used behind products and as aurora blobs.
  static RadialGradient botanicalGlow(Color color) => RadialGradient(
        colors: [color, color.withValues(alpha: 0)],
      );
}
