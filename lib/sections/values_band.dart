import 'package:flutter/material.dart';

/// Edge-to-edge brand-values image strip. A single full-width image that scales
/// identically on mobile and desktop.
class ValuesBand extends StatelessWidget {
  const ValuesBand({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ValuesBand.webp',
      width: double.infinity,
      fit: BoxFit.fitWidth,
      errorBuilder: (c, e, s) => const SizedBox.shrink(),
    );
  }
}
