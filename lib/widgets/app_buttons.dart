import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_durations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_gradients.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_text_styles.dart';

enum _ButtonKind { primary, secondary }

class _HoverButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final _ButtonKind kind;
  final bool dense;
  final bool gold; // foiled-gold signature CTA (use sparingly)

  const _HoverButton({
    required this.text,
    required this.onPressed,
    required this.kind,
    this.icon,
    this.dense = false,
    this.gold = false,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.kind == _ButtonKind.primary;
    final primary = AppColors.primaryGreen;
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final pad = widget.dense
        ? const EdgeInsets.symmetric(horizontal: 22, vertical: 13)
        : const EdgeInsets.symmetric(horizontal: 30, vertical: 17);

    final Color glow = widget.gold ? AppColors.gold : AppColors.primaryGreen;
    final Color fg = isPrimary
        ? (widget.gold ? AppColors.darkGreen : Colors.white)
        : (_hover ? Colors.white : primary);

    final scale = reduce
        ? 1.0
        : _pressed
            ? AppDimens.pressedScale
            : 1.0;
    final lift = (_hover && !reduce) ? AppDimens.buttonLiftY : 0.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: scale,
          duration: AppDurations.micro,
          curve: AppCurves.standard,
          child: AnimatedContainer(
            duration: AppDurations.hover,
            curve: AppCurves.standard,
            transform: Matrix4.identity()
              ..translateByDouble(0.0, lift, 0.0, 1.0),
            padding: pad,
            decoration: BoxDecoration(
              color: isPrimary && !widget.gold
                  ? (_hover ? AppColors.darkGreen : AppColors.primaryGreen)
                  : (isPrimary ? null : (_hover ? primary : Colors.transparent)),
              gradient: isPrimary && widget.gold ? AppGradients.goldFoil : null,
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              border: isPrimary
                  ? null
                  : Border.all(color: AppColors.primaryGreen, width: 1.6),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: glow.withValues(alpha: _hover ? 0.40 : 0.24),
                        blurRadius: _hover ? 28 : 16,
                        offset: Offset(0, _hover ? 12 : 7),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 18, color: fg),
                  const SizedBox(width: 8),
                ],
                Text(widget.text,
                    style: AppTextStyles.button.copyWith(color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool dense;

  /// Foiled-gold signature variant — reserve for the hero & checkout CTAs.
  final bool gold;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.dense = false,
    this.gold = false,
  });

  @override
  Widget build(BuildContext context) => _HoverButton(
        text: text,
        onPressed: onPressed,
        icon: icon,
        dense: dense,
        gold: gold,
        kind: _ButtonKind.primary,
      );
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool dense;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) => _HoverButton(
        text: text,
        onPressed: onPressed,
        icon: icon,
        dense: dense,
        kind: _ButtonKind.secondary,
      );
}
