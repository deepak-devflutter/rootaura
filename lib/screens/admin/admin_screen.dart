import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/shop_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/order.dart';
import '../../data/order_repository.dart';
import '../../data/products_repository.dart';
import '../../data/seed_data.dart';
import '../../utils/format.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/section.dart';
import '../../widgets/status_badge.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _seeding = false;

  Future<void> _seed() async {
    setState(() => _seeding = true);
    try {
      await seedProducts();
      ProductsRepository.instance.load(forceRefresh: true);
      _toast('Products seeded to Firestore.');
    } catch (e) {
      _toast('Seeding failed: $e');
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return PageScaffold(
      body: SectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Admin · Orders',
                    style: AppTextStyles.h1.copyWith(color: brand.textPrimary)),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _seeding ? null : _seed,
                  icon: _seeding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.cloud_upload_outlined, size: 18),
                  label: const Text('Seed products'),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.lg),
            StreamBuilder<List<ShopOrder>>(
              stream: OrderRepository.instance.allOrders(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(AppDimens.xxl),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snap.hasError) {
                  return Text('Could not load orders (check admin access).',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.berry));
                }
                final orders = snap.data ?? const [];
                if (orders.isEmpty) {
                  return Text('No orders yet.',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: brand.textSecondary));
                }
                return Column(
                  children: orders.map((o) => _AdminOrderCard(order: o)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final ShopOrder order;
  const _AdminOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.md),
      child: Container(
        decoration: BoxDecoration(
          color: brand.card,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: brand.border),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: AppDimens.lg, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(
                AppDimens.lg, 0, AppDimens.lg, AppDimens.lg),
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '#${order.id.substring(0, order.id.length.clamp(0, 8))}  ·  ${order.customerName}',
                          style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: brand.textPrimary)),
                      const SizedBox(height: 2),
                      Text(
                          '${Format.dateTime(order.createdAt)} · ${ShopConfig.money(order.total)} · ${order.paymentMethod.toUpperCase()}',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: brand.textSecondary)),
                    ],
                  ),
                ),
                StatusBadge(order.status),
              ],
            ),
            children: [
              _kv(brand, 'Phone', order.customerPhone),
              _kv(brand, 'Address', order.address.oneLine),
              if (order.upiRef != null)
                _kv(brand, 'UPI Ref', order.upiRef!),
              const SizedBox(height: AppDimens.sm),
              ...order.items.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(child: Text('${i.name} × ${i.qty}')),
                        Text(ShopConfig.money(i.lineTotal)),
                      ],
                    ),
                  )),
              const Divider(),
              Row(
                children: [
                  StatusBadge(order.paymentStatus, isPayment: true),
                  const Spacer(),
                  if (order.paymentStatus != PaymentStatus.paid)
                    TextButton.icon(
                      onPressed: () =>
                          OrderRepository.instance.markPaid(order.id),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Mark paid'),
                    ),
                ],
              ),
              const SizedBox(height: AppDimens.sm),
              Row(
                children: [
                  Text('Update status:',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: brand.textSecondary)),
                  const SizedBox(width: AppDimens.sm),
                  DropdownButton<String>(
                    value: order.status,
                    items: [...OrderStatus.flow, OrderStatus.cancelled]
                        .map((s) => DropdownMenuItem(
                            value: s, child: Text(OrderStatus.label(s))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        OrderRepository.instance.updateStatus(order.id, v);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kv(BrandColors brand, String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 70,
                child: Text(k,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: brand.textSecondary))),
            Expanded(
                child: Text(v,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: brand.textPrimary))),
          ],
        ),
      );
}
