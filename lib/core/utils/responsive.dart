import 'package:flutter/widgets.dart';

import '../constants/app_dimens.dart';

/// Screen-size helpers used across sections for responsive layout.
class Responsive {
  Responsive._();

  static double width(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isMobile(BuildContext context) =>
      width(context) < AppDimens.mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      width(context) >= AppDimens.mobileBreakpoint &&
      width(context) < AppDimens.tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      width(context) >= AppDimens.tabletBreakpoint;

  /// Picks a value per breakpoint, falling back sensibly.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? desktop;
    return desktop;
  }

  static double sectionPaddingV(BuildContext context) =>
      isMobile(context) ? AppDimens.sectionMobile : AppDimens.section;

  static double sectionPaddingH(BuildContext context) =>
      isMobile(context) ? AppDimens.lg : AppDimens.xxxl;
}
