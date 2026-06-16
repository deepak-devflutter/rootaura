import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/order.dart';

/// Small coloured pill for an order or payment status.
class StatusBadge extends StatelessWidget {
  final String status;
  final bool isPayment;
  const StatusBadge(this.status, {super.key, this.isPayment = false});

  Color get _color {
    if (isPayment) {
      return status == PaymentStatus.paid
          ? const Color(0xFF1E8E4E)
          : const Color(0xFFB7791F);
    }
    switch (status) {
      case OrderStatus.delivered:
        return const Color(0xFF1E8E4E);
      case OrderStatus.shipped:
        return const Color(0xFF0E7C86);
      case OrderStatus.packed:
        return const Color(0xFF4F46E5);
      case OrderStatus.confirmed:
        return const Color(0xFF2563EB);
      case OrderStatus.cancelled:
        return const Color(0xFFD64550);
      default:
        return const Color(0xFFB7791F); // placed
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = isPayment
        ? (status == PaymentStatus.paid ? 'Paid' : 'Payment pending')
        : OrderStatus.label(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(label,
          style: AppTextStyles.bodySmall
              .copyWith(color: _color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}
