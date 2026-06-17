import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/constants/app_durations.dart';
import '../core/theme/app_motion.dart';

/// Reveals its child the first time it scrolls into view with the signature
/// botanical entrance: fade + rise + a subtle settle-scale, all on
/// [AppCurves.entrance]. [delay] drives staggered cascades.
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double offsetY;

  const ScrollReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 28,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  static int _counter = 0;
  late final Key _key = ValueKey('reveal_${_counter++}');

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: AppDurations.enter,
  );
  late final Animation<double> _t =
      CurvedAnimation(parent: _c, curve: AppCurves.entrance);
  bool _started = false;

  void _onVisibility(VisibilityInfo info) {
    if (_started || info.visibleFraction <= 0.12 || !mounted) return;
    _started = true;
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) return widget.child;

    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: _onVisibility,
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, child) {
          final v = _t.value;
          return Opacity(
            opacity: v.clamp(0, 1),
            child: Transform.translate(
              offset: Offset(0, (1 - v) * widget.offsetY),
              child: Transform.scale(
                scale: 0.98 + 0.02 * v,
                alignment: Alignment.center,
                child: child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
