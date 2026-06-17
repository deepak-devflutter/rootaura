import 'package:flutter/material.dart';

/// Typography scale — premium editorial pairing using **bundled** fonts
/// (no runtime fetch): Fraunces (serif display/headings), Poppins (component
/// titles/labels), Inter (body). Colours come from the active theme.
class AppTextStyles {
  AppTextStyles._();

  static const String fraunces = 'Fraunces';
  static const String poppins = 'Poppins';
  static const String inter = 'Inter';

  static const TextStyle display = TextStyle(
    fontFamily: fraunces,
    fontSize: 72,
    fontWeight: FontWeight.w600,
    height: 1.02,
    letterSpacing: -1.6,
  );

  /// Oversized decorative serif numeral (01 / 02 / 03 process layouts).
  static const TextStyle accentNumeral = TextStyle(
    fontFamily: fraunces,
    fontSize: 120,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: -2,
  );

  static const TextStyle displayMobile = TextStyle(
    fontFamily: fraunces,
    fontSize: 40,
    fontWeight: FontWeight.w600,
    height: 1.06,
    letterSpacing: -0.6,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: fraunces,
    fontSize: 42,
    fontWeight: FontWeight.w600,
    height: 1.12,
    letterSpacing: -0.5,
  );

  static const TextStyle h1Mobile = TextStyle(
    fontFamily: fraunces,
    fontSize: 30,
    fontWeight: FontWeight.w600,
    height: 1.15,
    letterSpacing: -0.3,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fraunces,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // Component-level titles stay sans for UI clarity at small sizes.
  static const TextStyle h3 = TextStyle(
    fontFamily: poppins,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle eyebrow = TextStyle(
    fontFamily: poppins,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );

  /// The signature gold section label (colour applied at the call site).
  static const TextStyle eyebrowGold = TextStyle(
    fontFamily: poppins,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.0,
  );

  /// Tabular-figure numerals for prices/totals/IDs/KPIs (no layout shift).
  static const TextStyle numeric = TextStyle(
    fontFamily: inter,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Editorial serif price (used on PDP, summary, totals).
  static const TextStyle price = TextStyle(
    fontFamily: fraunces,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: inter,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.7,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: inter,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.65,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: inter,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle button = TextStyle(
    fontFamily: poppins,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle navItem = TextStyle(
    fontFamily: poppins,
    fontSize: 14.5,
    fontWeight: FontWeight.w500,
  );
}
