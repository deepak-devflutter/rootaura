import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Compact − [qty] + control used in the cart and product detail.
class QtyStepper extends StatelessWidget {
  final int qty;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const QtyStepper({
    super.key,
    required this.qty,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Container(
      decoration: BoxDecoration(
        color: brand.cardSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: brand.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove_rounded,
              qty > min ? () => onChanged(qty - 1) : null),
          SizedBox(
            width: 32,
            child: Text('$qty',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700, color: brand.textPrimary)),
          ),
          _btn(Icons.add_rounded, qty < max ? () => onChanged(qty + 1) : null),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon,
            size: 18,
            color: onTap == null ? Colors.grey : AppColors.primaryGreen),
      ),
    );
  }
}
