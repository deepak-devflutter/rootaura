import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/shop_config.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/order.dart';
import '../data/order_repository.dart';
import '../state/auth_controller.dart';
import '../utils/format.dart';
import '../widgets/app_buttons.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/section.dart';
import '../widgets/status_badge.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthController.instance.user?.uid;
    return PageScaffold(
      body: SectionContainer(
        maxWidth: 820,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Orders',
                style:
                    AppTextStyles.h1.copyWith(color: context.brand.textPrimary)),
            const SizedBox(height: AppDimens.lg),
            if (uid == null)
              const SizedBox()
            else
              StreamBuilder<List<ShopOrder>>(
                stream: OrderRepository.instance.ordersForUser(uid),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(AppDimens.xxl),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final orders = snap.data ?? const [];
                  if (orders.isEmpty) return _empty(context);
                  return Column(
                    children:
                        orders.map((o) => _OrderTile(order: o)).toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final brand = context.brand;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.xxl),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 56, color: brand.textSecondary),
          const SizedBox(height: AppDimens.md),
          Text('No orders yet',
              style: AppTextStyles.h3.copyWith(color: brand.textPrimary)),
          const SizedBox(height: AppDimens.md),
          PrimaryButton(
            text: 'Start Shopping',
            onPressed: () => context.go(AppRoutes.products),
          ),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final ShopOrder order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: InkWell(
        onTap: () => context.push(AppRoutes.orderDetailPath(order.id)),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.lg),
          decoration: BoxDecoration(
            color: brand.card,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(color: brand.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('#${order.id.substring(0, order.id.length.clamp(0, 8))}',
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: brand.textPrimary)),
                  const Spacer(),
                  StatusBadge(order.status),
                ],
              ),
              const SizedBox(height: AppDimens.sm),
              Text(
                  '${Format.date(order.createdAt)} · ${order.itemCount} item(s)',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: brand.textSecondary)),
              const SizedBox(height: AppDimens.sm),
              Row(
                children: [
                  Text(ShopConfig.money(order.total),
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen)),
                  const Spacer(),
                  Text('View details →',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.primaryGreen)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
