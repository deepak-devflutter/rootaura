import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/order.dart';

/// Maps an order/payment status to a single earthy colour ramp (green ladder +
/// gold + berry) — no foreign blues/indigos. Exposed so the order timeline can
/// reuse the exact same styling.
Color statusColor(String status, {bool isPayment = false}) {
  if (isPayment) {
    return status == PaymentStatus.paid ? AppColors.primaryGreen : AppColors.gold;
  }
  switch (status) {
    case OrderStatus.delivered:
      return AppColors.darkGreen;
    case OrderStatus.shipped:
      return AppColors.primaryGreen;
    case OrderStatus.packed:
      return AppColors.midGreen;
    case OrderStatus.confirmed:
      return AppColors.softGreen;
    case OrderStatus.cancelled:
      return AppColors.berry;
    default:
      return AppColors.gold; // placed
  }
}

/// A dot + tinted pill with an uppercase eyebrow label.
class StatusBadge extends StatelessWidget {
  final String status;
  final bool isPayment;
  const StatusBadge(this.status, {super.key, this.isPayment = false});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status, isPayment: isPayment);
    final label = isPayment
        ? (status == PaymentStatus.paid ? 'Paid' : 'Payment pending')
        : OrderStatus.label(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label.toUpperCase(),
              style: AppTextStyles.eyebrow.copyWith(
                  color: color, fontSize: 11, letterSpacing: 0.8)),
        ],
      ),
    );
  }
}
