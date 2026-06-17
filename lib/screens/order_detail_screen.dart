import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/shop_config.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/cart_item.dart';
import '../data/models/order.dart';
import '../data/order_repository.dart';
import '../data/products_repository.dart';
import '../state/cart_controller.dart';
import '../utils/format.dart';
import '../utils/url_helper.dart';
import '../widgets/app_buttons.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/section.dart';
import '../widgets/status_badge.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      ambient: true,
      body: SectionContainer(
        maxWidth: 720,
        child: StreamBuilder<ShopOrder?>(
          stream: OrderRepository.instance.streamOrder(orderId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(AppDimens.section),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final order = snap.data;
            if (order == null) {
              return Text('Order not found',
                  style: AppTextStyles.h3
                      .copyWith(color: context.brand.textPrimary));
            }
            return _detail(context, order);
          },
        ),
      ),
    );
  }

  Widget _detail(BuildContext context, ShopOrder o) {
    final brand = context.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.orders),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.arrow_back_rounded,
                size: 18, color: AppColors.primaryGreen),
            const SizedBox(width: 6),
            Text('Back to orders',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.primaryGreen)),
          ]),
        ),
        const SizedBox(height: AppDimens.md),
        Row(
          children: [
            Text('Order #${o.id.substring(0, o.id.length.clamp(0, 8))}',
                style: AppTextStyles.h2.copyWith(color: brand.textPrimary)),
            const Spacer(),
            StatusBadge(o.status),
          ],
        ),
        const SizedBox(height: AppDimens.xs),
        Text(Format.dateTime(o.createdAt),
            style:
                AppTextStyles.bodySmall.copyWith(color: brand.textSecondary)),
        const SizedBox(height: AppDimens.lg),
        _OrderTimeline(status: o.status),
        const SizedBox(height: AppDimens.xl),
        _card(brand, 'Items', Column(children: o.items.map(_itemRow).toList())),
        const SizedBox(height: AppDimens.md),
        _card(
          brand,
          'Delivery Address',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(o.address.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700, color: brand.textPrimary)),
              const SizedBox(height: 2),
              Text('${o.address.oneLine}\n${o.address.phone}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: brand.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.md),
        _card(
          brand,
          'Payment',
          Row(
            children: [
              Text(
                  o.paymentMethod == PaymentMethod.cod
                      ? 'Cash on Delivery'
                      : 'UPI${o.upiRef != null ? ' · ${o.upiRef}' : ''}',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: brand.textPrimary)),
              const Spacer(),
              StatusBadge(o.paymentStatus, isPayment: true),
            ],
          ),
        ),
        if ((o.note ?? '').isNotEmpty) ...[
          const SizedBox(height: AppDimens.md),
          _card(
            brand,
            'Your Note',
            Text(o.note!,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: brand.textSecondary)),
          ),
        ],
        if (o.hasShipment) ...[
          const SizedBox(height: AppDimens.md),
          _card(
            brand,
            'Shipment Tracking',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _billRow(brand, 'Courier', o.courier!),
                const SizedBox(height: 4),
                _billRow(brand, 'Tracking ID', o.trackingId!),
                if ((o.trackingUrl ?? '').isNotEmpty) ...[
                  const SizedBox(height: AppDimens.md),
                  SecondaryButton(
                    text: 'Track Shipment',
                    icon: Icons.local_shipping_outlined,
                    dense: true,
                    onPressed: () => UrlHelper.open(context, o.trackingUrl),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: AppDimens.md),
        _card(
          brand,
          'Bill',
          Column(children: [
            _billRow(brand, 'Subtotal', ShopConfig.money(o.subtotal)),
            if (o.discountAmount > 0) ...[
              const SizedBox(height: 6),
              _billRow(
                  brand,
                  'Discount (${o.discountPercent.toStringAsFixed(0)}%)',
                  '- ${ShopConfig.money(o.discountAmount)}'),
            ],
            const SizedBox(height: 6),
            _billRow(brand, 'Delivery',
                o.delivery == 0 ? 'FREE' : ShopConfig.money(o.delivery)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimens.sm),
              child: Divider(color: brand.border, height: 1),
            ),
            _billRow(brand, 'Total', ShopConfig.money(o.total), bold: true),
          ]),
        ),
        const SizedBox(height: AppDimens.xl),
        Wrap(
          spacing: AppDimens.md,
          runSpacing: AppDimens.md,
          children: [
            if (o.status == OrderStatus.placed)
              SecondaryButton(
                text: 'Cancel Order',
                icon: Icons.close_rounded,
                onPressed: () => _cancel(context, o),
              ),
            PrimaryButton(
              text: 'Reorder',
              icon: Icons.replay_rounded,
              onPressed: () => _reorder(context, o),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _cancel(BuildContext context, ShopOrder o) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this order?'),
        content: const Text(
            'You can cancel while the order is still being placed. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep order')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.berry),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cancel order')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await OrderRepository.instance.cancelByCustomer(o.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order cancelled.')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not cancel — it may already be processing.')));
      }
    }
  }

  Future<void> _reorder(BuildContext context, ShopOrder o) async {
    final products = await ProductsRepository.instance.load(forceRefresh: true);
    final byId = {for (final p in products) p.id: p};
    var added = 0;
    final unavailable = <String>[];
    for (final item in o.items) {
      final p = byId[item.productId];
      if (p != null && p.active && p.inStock) {
        CartController.instance.add(p, qty: item.qty);
        added++;
      } else {
        unavailable.add(item.name);
      }
    }
    if (!context.mounted) return;
    if (added == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('None of these items are available right now.')));
      return;
    }
    final msg = unavailable.isEmpty
        ? '$added item(s) added to cart'
        : '$added added · unavailable: ${unavailable.join(', ')}';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
    context.push(AppRoutes.cart);
  }

  Widget _itemRow(CartItem i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              child: Container(
                width: 44,
                height: 44,
                color: const Color(0x11000000),
                padding: const EdgeInsets.all(4),
                child: CachedNetworkImage(
                  imageUrl: i.image,
                  fit: BoxFit.contain,
                  errorWidget: (c, _, __) => const Icon(Icons.eco_rounded,
                      size: 18, color: AppColors.primaryGreen),
                ),
              ),
            ),
            const SizedBox(width: AppDimens.sm),
            Expanded(
                child: Text('${i.name}  × ${i.qty}',
                    style: const TextStyle(fontWeight: FontWeight.w500))),
            Text(ShopConfig.money(i.lineTotal),
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      );

  Widget _billRow(BrandColors brand, String label, String value,
          {bool bold = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: bold ? brand.textPrimary : brand.textSecondary,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
          Text(value,
              style: AppTextStyles.bodyMedium.copyWith(
                  color: brand.textPrimary,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ],
      );

  Widget _card(BrandColors brand, String title, Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimens.lg),
        decoration: BoxDecoration(
          color: brand.card,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: brand.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: AppTextStyles.h3
                    .copyWith(color: brand.textPrimary, fontSize: 16)),
            const SizedBox(height: AppDimens.md),
            child,
          ],
        ),
      );
}

class _OrderTimeline extends StatelessWidget {
  final String status;
  const _OrderTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    if (status == OrderStatus.cancelled) {
      return Row(children: [
        const Icon(Icons.cancel_rounded, color: AppColors.berry),
        const SizedBox(width: AppDimens.sm),
        Text('This order was cancelled.',
            style:
                AppTextStyles.bodyMedium.copyWith(color: brand.textPrimary)),
      ]);
    }
    final currentIndex = OrderStatus.flow.indexOf(status);
    return Row(
      children: List.generate(OrderStatus.flow.length, (i) {
        final done = i <= currentIndex;
        final isLast = i == OrderStatus.flow.length - 1;
        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Icon(
                      done
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: done ? AppColors.primaryGreen : brand.border,
                      size: 22),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 64,
                    child: Text(OrderStatus.label(OrderStatus.flow[i]),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: done
                                ? brand.textPrimary
                                : brand.textSecondary)),
                  ),
                ],
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    color: i < currentIndex
                        ? AppColors.primaryGreen
                        : brand.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
