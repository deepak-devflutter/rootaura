import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/shop_config.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/order.dart';
import '../data/order_repository.dart';
import '../widgets/app_buttons.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/section.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return PageScaffold(
      ambient: true,
      body: SectionContainer(
        maxWidth: 560,
        child: FutureBuilder<ShopOrder?>(
          future: OrderRepository.instance.byId(orderId),
          builder: (context, snap) {
            final order = snap.data;
            return Column(
              children: [
                SvgPicture.asset('assets/empty/order-success.svg', width: 150),
                const SizedBox(height: AppDimens.lg),
                Text('Order placed!',
                    style:
                        AppTextStyles.h1.copyWith(color: brand.textPrimary)),
                const SizedBox(height: AppDimens.sm),
                Text(
                    'Thank you for your order. We’ll confirm it shortly'
                    '${order?.paymentMethod == PaymentMethod.upi ? ' once your UPI payment is verified.' : '.'}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: brand.textSecondary)),
                const SizedBox(height: AppDimens.lg),
                Container(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  decoration: BoxDecoration(
                    color: brand.cardSoft,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  ),
                  child: Column(
                    children: [
                      _row(brand, 'Order ID', '#${orderId.substring(0, orderId.length.clamp(0, 8))}'),
                      if (order != null) ...[
                        const SizedBox(height: AppDimens.sm),
                        _row(brand, 'Items', '${order.itemCount}'),
                        const SizedBox(height: AppDimens.sm),
                        _row(brand, 'Total', ShopConfig.money(order.total)),
                        const SizedBox(height: AppDimens.sm),
                        _row(brand, 'Payment',
                            order.paymentMethod == PaymentMethod.cod
                                ? 'Cash on Delivery'
                                : 'UPI'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.xl),
                Wrap(
                  spacing: AppDimens.md,
                  runSpacing: AppDimens.md,
                  alignment: WrapAlignment.center,
                  children: [
                    PrimaryButton(
                      text: 'View My Orders',
                      onPressed: () => context.go(AppRoutes.orders),
                    ),
                    SecondaryButton(
                      text: 'Continue Shopping',
                      onPressed: () => context.go(AppRoutes.products),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(BrandColors brand, String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: brand.textSecondary)),
          Text(value,
              style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700, color: brand.textPrimary)),
        ],
      );
}
