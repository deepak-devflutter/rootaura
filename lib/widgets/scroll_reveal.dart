import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../core/constants/app_durations.dart';

/// Fades and slides its child up the first time it scrolls into view.
/// Gives the page the polished, "professionally built" entrance feel.
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double offsetY;

  const ScrollReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 36,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> {
  static int _counter = 0;
  late final Key _key = ValueKey('reveal_${_counter++}');
  bool _shown = false;

  void _onVisibility(VisibilityInfo info) {
    if (!_shown && info.visibleFraction > 0.12 && mounted) {
      setState(() => _shown = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _key,
      onVisibilityChanged: _onVisibility,
      child: AnimatedSlide(
        offset: _shown ? Offset.zero : Offset(0, widget.offsetY / 100),
        duration: AppDurations.reveal,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _shown ? 1 : 0,
          duration: AppDurations.reveal,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
