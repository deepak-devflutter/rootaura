import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/shop_config.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'app_buttons.dart';

/// Reusable price breakdown card (subtotal → delivery → total) with an optional
/// action button. Used on the cart and checkout screens.
class OrderSummary extends StatelessWidget {
  final double subtotal;
  final double discountPercent; // per-customer VIP discount
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool busy;
  final Widget? extra; // e.g. payment selector slotted above the button

  const OrderSummary({
    super.key,
    required this.subtotal,
    this.discountPercent = 0,
    this.actionLabel,
    this.onAction,
    this.busy = false,
    this.extra,
  });

  /// Discount amount, rounded to whole rupees so totals stay exact.
  static double discountFor(double subtotal, double percent) =>
      (subtotal * percent / 100).roundToDouble();

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final delivery = ShopConfig.deliveryFor(subtotal);
    final discount = discountFor(subtotal, discountPercent);
    final total = subtotal + delivery - discount;

    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: brand.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: brand.border),
        boxShadow: [
          BoxShadow(color: brand.shadow, blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Order Summary',
              style: AppTextStyles.h3
                  .copyWith(color: brand.textPrimary, fontSize: 18)),
          const SizedBox(height: AppDimens.md),
          _row(brand, 'Subtotal', ShopConfig.money(subtotal)),
          if (discount > 0) ...[
            const SizedBox(height: AppDimens.sm),
            _row(
              brand,
              'Discount (${discountPercent.toStringAsFixed(0)}%)',
              '- ${ShopConfig.money(discount)}',
              highlight: true,
            ),
          ],
          const SizedBox(height: AppDimens.sm),
          _row(
            brand,
            'Delivery',
            delivery == 0 ? 'FREE' : ShopConfig.money(delivery),
            highlight: delivery == 0,
          ),
          if (delivery > 0) ...[
            const SizedBox(height: 4),
            Text(
                'Free delivery on orders over ${ShopConfig.money(ShopConfig.freeDeliveryOver)}',
                style: AppTextStyles.bodySmall
                    .copyWith(color: brand.textSecondary, fontSize: 11)),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
            child: Divider(color: brand.border, height: 1),
          ),
          _row(brand, 'Total', ShopConfig.money(total), bold: true),
          if (extra != null) ...[
            const SizedBox(height: AppDimens.lg),
            extra!,
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: AppDimens.lg),
            busy
                ? const Center(child: CircularProgressIndicator())
                : PrimaryButton(
                    text: actionLabel!,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: onAction ?? () {},
                  ),
          ],
        ],
      ),
    );
  }

  Widget _row(BrandColors brand, String label, String value,
      {bool bold = false, bool highlight = false}) {
    final style = (bold ? AppTextStyles.h3 : AppTextStyles.bodyMedium).copyWith(
      color: highlight ? AppColors.primaryGreen : brand.textPrimary,
      fontSize: bold ? 20 : 15,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMedium.copyWith(
                color: bold ? brand.textPrimary : brand.textSecondary,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                fontSize: bold ? 18 : 15)),
        Text(value, style: style),
      ],
    );
  }
}
