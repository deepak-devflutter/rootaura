import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Read-only star row. Supports half stars for averages.
class StarRating extends StatelessWidget {
  final double value; // 0..5
  final double size;
  final Color? color;
  const StarRating(this.value, {super.key, this.size = 18, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.gold;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = value >= i + 1;
        final half = !filled && value > i;
        return Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          size: size,
          color: c,
        );
      }),
    );
  }
}

/// Interactive star selector for writing a review.
class StarInput extends StatelessWidget {
  final int value; // 1..5 (0 = none)
  final ValueChanged<int> onChanged;
  final double size;
  const StarInput(
      {super.key, required this.value, required this.onChanged, this.size = 34});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = value >= i + 1;
        return IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          constraints: const BoxConstraints(),
          onPressed: () => onChanged(i + 1),
          icon: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: AppColors.gold,
          ),
        );
      }),
    );
  }
}
