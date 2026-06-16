import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_durations.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

enum _ButtonKind { primary, secondary }

class _HoverButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final _ButtonKind kind;
  final bool dense;

  const _HoverButton({
    required this.text,
    required this.onPressed,
    required this.kind,
    this.icon,
    this.dense = false,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.kind == _ButtonKind.primary;
    final primary = Theme.of(context).colorScheme.primary;
    final pad = widget.dense
        ? const EdgeInsets.symmetric(horizontal: 22, vertical: 13)
        : const EdgeInsets.symmetric(horizontal: 30, vertical: 17);

    final Color bg = isPrimary
        ? (_hover ? AppColors.darkGreen : AppColors.primaryGreen)
        : (_hover ? AppColors.primaryGreen : Colors.transparent);
    final Color fg = isPrimary
        ? Colors.white
        : (_hover ? Colors.white : primary);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translateByDouble(0.0, _hover ? -2.0 : 0.0, 0.0, 1.0),
          padding: pad,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            border: isPrimary
                ? null
                : Border.all(color: AppColors.primaryGreen, width: 1.6),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primaryGreen
                          .withValues(alpha: _hover ? 0.35 : 0.22),
                      blurRadius: _hover ? 24 : 14,
                      offset: Offset(0, _hover ? 10 : 6),
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
              Text(widget.text, style: AppTextStyles.button.copyWith(color: fg)),
            ],
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

  const PrimaryButton({
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
