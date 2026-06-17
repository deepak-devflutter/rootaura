/// Animation timing tokens for consistent motion across the app.
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration reveal = Duration(milliseconds: 700);
  static const Duration scrollTo = Duration(milliseconds: 800);

  // Curve-paired interaction tokens (see AppCurves).
  static const Duration micro = Duration(milliseconds: 120); // press
  static const Duration hover = Duration(milliseconds: 220);
  static const Duration hoverOut = Duration(milliseconds: 350);
  static const Duration enter = Duration(milliseconds: 520); // staggered item
  static const Duration page = Duration(milliseconds: 600); // route
  static const Duration hero = Duration(milliseconds: 720);

  /// Per-item delay for staggered grids/lists.
  static const Duration staggerStep = Duration(milliseconds: 75);
}
