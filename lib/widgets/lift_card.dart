import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_durations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_elevation.dart';
import '../core/theme/app_motion.dart';

/// The signature "specimen lift": a surface that rests on a warm 2-layer
/// shadow (e2) and rises (e3/e4 + slight scale) on hover, with a press-down.
/// One controller of truth for depth + motion across every card/tile/row.
///
/// Pass [builder] instead of [child] to react to the hover state (e.g. to zoom
/// an inner image in sync with the lift).
class LiftCard extends StatefulWidget {
  final Widget? child;
  final Widget Function(BuildContext context, bool hovered)? builder;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final bool bordered;
  final double liftY;
  final bool interactive;

  const LiftCard({
    super.key,
    this.child,
    this.builder,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.color,
    this.bordered = true,
    this.liftY = AppDimens.hoverLiftY,
    this.interactive = true,
  });

  @override
  State<LiftCard> createState() => _LiftCardState();
}

class _LiftCardState extends State<LiftCard> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final radius =
        widget.borderRadius ?? BorderRadius.circular(AppDimens.radiusLg);
    final lifted = widget.interactive && _hover && !reduce;

    final scale = !widget.interactive || reduce
        ? 1.0
        : _pressed
            ? AppDimens.pressedScale
            : _hover
                ? AppDimens.hoverScale
                : 1.0;

    Widget content = AnimatedContainer(
      duration: lifted ? AppDurations.hover : AppDurations.hoverOut,
      curve: AppCurves.standard,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.color ?? brand.card,
        borderRadius: radius,
        border: widget.bordered
            ? Border.all(
                color: lifted
                    ? AppColors.gold.withValues(alpha: 0.45)
                    : brand.border)
            : null,
        boxShadow:
            lifted ? AppElevation.e4(dark) : AppElevation.e2(dark),
      ),
      child: widget.builder?.call(context, _hover) ?? widget.child,
    );

    content = AnimatedScale(
      duration: lifted ? AppDurations.hover : AppDurations.hoverOut,
      curve: AppCurves.standard,
      scale: scale,
      child: AnimatedSlide(
        duration: lifted ? AppDurations.hover : AppDurations.hoverOut,
        curve: AppCurves.standard,
        offset: Offset(0, lifted ? widget.liftY / 100 : 0),
        child: content,
      ),
    );

    if (!widget.interactive && widget.onTap == null) return content;

    return MouseRegion(
      cursor:
          widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: content,
      ),
    );
  }
}
