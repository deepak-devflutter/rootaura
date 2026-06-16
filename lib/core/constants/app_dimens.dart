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
  static const double section = 100; // vertical section padding (desktop)
  static const double sectionMobile = 64;

  // Radius
  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
  static const double radiusPill = 999;

  // Layout
  static const double maxContentWidth = 1200;
  static const double headerHeight = 76;
  static const double cardWidth = 320;

  // Breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1100;
}
