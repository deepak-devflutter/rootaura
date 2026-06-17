import 'package:flutter/widgets.dart';

/// The single source of motion truth — "Botanical motion": everything settles
/// into place on a gentle expo-out, never snaps. All widgets pull curves from
/// here instead of raw `Curves.*`.
class AppCurves {
  AppCurves._();

  /// Reveals, entrances, hero — the "settles into place" feel.
  static const Cubic entrance = Cubic(0.16, 1.0, 0.3, 1.0);

  /// Page / shared-element transitions.
  static const Cubic emphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Hovers, condensing, quick UI moves.
  static const Curve standard = Curves.easeOutCubic;

  /// Chips / dots / small pops.
  static const Curve overshoot = Curves.easeOutBack;

  /// Cart pops & badge bounces.
  static final SpringDescription spring =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 180, ratio: 0.75);
}
