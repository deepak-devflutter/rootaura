/// Spacing, radius, and layout tokens. No magic numbers in widgets.
class AppDimens {
  AppDimens._();

  // Spacing scale
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
  static const double section = 128; // vertical section padding (desktop)
  static const double sectionMobile = 72;

  // Radius — crisp-small for chips/inputs, soft-organic for cards/images
  static const double radiusSm = 12;
  static const double radiusMd = 14;
  static const double radiusLg = 24;
  static const double radiusXl = 30;
  static const double radiusPill = 999;

  // Interaction tokens (so widgets stop hardcoding transforms)
  static const double hoverLiftY = -6; // cards
  static const double rowLiftY = -4; // list rows
  static const double buttonLiftY = -2;
  static const double pressedScale = 0.97;
  static const double hoverScale = 1.015;

  // Layout
  static const double maxContentWidth = 1200;
  static const double contentNarrow = 920; // editorial / about
  static const double contentWide = 1320; // testimonials / galleries
  static const double headerHeight = 76;
  static const double cardWidth = 320;

  // Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1100;
}
