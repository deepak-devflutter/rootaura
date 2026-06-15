
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isHovered
                ? AppColors.darkGreen
                : AppColors.primaryGreen,
            foregroundColor: AppColors.surface,
            padding: const EdgeInsets.symmetric(
              horizontal: 36,
              vertical: 18,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: _isHovered ? 8 : 4,
            shadowColor: AppColors.primaryGreen.withValues(alpha: 0.4),
          ),
          child: Text(
            widget.text,
            style: AppTextStyles.button,
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: OutlinedButton(
          onPressed: widget.onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: _isHovered
                ? AppColors.surface
                : AppColors.primaryGreen,
            backgroundColor: _isHovered
                ? AppColors.primaryGreen
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: 36,
              vertical: 18,
            ),
            side: BorderSide(
              color: AppColors.primaryGreen,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            widget.text,
            style: AppTextStyles.button.copyWith(
              color: _isHovered
                  ? AppColors.surface
                  : AppColors.primaryGreen,
            ),
          ),
        ),
      ),
    );
  }
}

