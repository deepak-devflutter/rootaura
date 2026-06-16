import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/shop_config.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/order.dart';
import '../../data/models/user_profile.dart';
import '../../data/order_repository.dart';
import '../../data/user_repository.dart';
import '../../utils/format.dart';
import '../../utils/url_helper.dart';
import '../../widgets/status_badge.dart';

/// Full customer profile for the admin: identity, lifetime stats, addresses,
/// order history, and the management controls (role, discount, block, notes).
class CustomerDetailScreen extends StatelessWidget {
  final String uid;
  const CustomerDetailScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Scaffold(
      appBar: AppBar(title: const Text('Customer')),
      body: StreamBuilder<UserProfile?>(
        stream: UserRepository.instance.streamUser(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snap.data;
          if (profile == null) {
            return Center(
                child: Text('Customer not found',
                    style: AppTextStyles.h3
                        .copyWith(color: brand.textPrimary)));
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.lg),
                children: [
                  _header(context, profile),
                  const SizedBox(height: AppDimens.lg),
                  _OrdersAndStats(uid: uid),
                  const SizedBox(height: AppDimens.lg),
                  _AdminControls(profile: profile),
                  const SizedBox(height: AppDimens.lg),
                  _addresses(context, profile),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, UserProfile p) {
    final brand = context.brand;
    return Container(
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
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    AppColors.primaryGreen.withValues(alpha: 0.12),
                child: Text(
                    (p.name.isNotEmpty ? p.name : '?')
                        .characters
                        .first
                        .toUpperCase(),
                    style: AppTextStyles.h2
                        .copyWith(color: AppColors.primaryGreen)),
              ),
              const SizedBox(width: AppDimens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name.isNotEmpty ? p.name : 'Unnamed customer',
                        style: AppTextStyles.h2
                            .copyWith(color: brand.textPrimary)),
                    if (p.createdAt != null)
                      Text('Member since ${Format.date(p.createdAt!)}',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: brand.textSecondary)),
                  ],
                ),
              ),
              Wrap(
                spacing: 4,
                children: [
                  if (p.isAdmin) _tag('Admin', const Color(0xFF4F46E5)),
                  if (p.blocked) _tag('Blocked', AppColors.berry),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Wrap(
            spacing: AppDimens.sm,
            runSpacing: AppDimens.sm,
            children: [
              if (p.phone.isNotEmpty)
                _contactChip(Icons.call_outlined, p.phone, 'tel:${p.phone}'),
              if (p.phone.isNotEmpty)
                _contactChip(Icons.chat_outlined, 'WhatsApp',
                    'https://wa.me/${p.phone.replaceAll(RegExp(r'\D'), '')}'),
              if (p.email.isNotEmpty)
                _contactChip(
                    Icons.email_outlined, p.email, 'mailto:${p.email}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactChip(IconData icon, String label, String url) => ActionChip(
        avatar: Icon(icon, size: 16, color: AppColors.primaryGreen),
        label: Text(label),
        onPressed: () => UrlHelper.launch(url),
      );

  Widget _addresses(BuildContext context, UserProfile p) {
    final brand = context.brand;
    return Container(
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
          Text('Saved Addresses (${p.addresses.length})',
              style: AppTextStyles.h3
                  .copyWith(color: brand.textPrimary, fontSize: 16)),
          const SizedBox(height: AppDimens.sm),
          if (p.addresses.isEmpty)
            Text('No saved addresses.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: brand.textSecondary))
          else
            ...p.addresses.map((a) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 18, color: AppColors.primaryGreen),
                      const SizedBox(width: AppDimens.sm),
                      Expanded(
                        child: Text(
                            '${a.label} · ${a.name}\n${a.oneLine} · ${a.phone}',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: brand.textPrimary)),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        ),
        child: Text(text,
            style: AppTextStyles.bodySmall.copyWith(
                color: color, fontWeight: FontWeight.w700, fontSize: 11)),
      );
}

/// Lifetime stats + order history, computed live from the customer's orders.
class _OrdersAndStats extends StatelessWidget {
  final String uid;
  const _OrdersAndStats({required this.uid});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return StreamBuilder<List<ShopOrder>>(
      stream: OrderRepository.instance.ordersForUser(uid),
      builder: (context, snap) {
        final orders = snap.data ?? const [];
        final paidOrders =
            orders.where((o) => o.status != OrderStatus.cancelled).toList();
        final spent = paidOrders.fold<double>(0, (s, o) => s + o.total);
        final avg = paidOrders.isEmpty ? 0.0 : spent / paidOrders.length;
        final last = orders.isEmpty ? null : orders.first.createdAt;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _stat(context, 'Orders', '${orders.length}'),
                _stat(context, 'Lifetime value', ShopConfig.money(spent)),
                _stat(context, 'Avg order', ShopConfig.money(avg)),
              ],
            ),
            if (last != null)
              Padding(
                padding: const EdgeInsets.only(top: AppDimens.sm),
                child: Text('Last order: ${Format.date(last)}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: brand.textSecondary)),
              ),
            const SizedBox(height: AppDimens.lg),
            Text('Order history',
                style: AppTextStyles.h3
                    .copyWith(color: brand.textPrimary, fontSize: 16)),
            const SizedBox(height: AppDimens.sm),
            if (snap.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.all(AppDimens.lg),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (orders.isEmpty)
              Text('No orders yet.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: brand.textSecondary))
            else
              ...orders.map((o) => _orderRow(context, o)),
          ],
        );
      },
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
    final brand = context.brand;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: AppDimens.sm),
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: brand.cardSoft,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: AppTextStyles.h3
                    .copyWith(color: brand.textPrimary, fontSize: 18)),
            Text(label,
                style: AppTextStyles.bodySmall
                    .copyWith(color: brand.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _orderRow(BuildContext context, ShopOrder o) {
    final brand = context.brand;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.sm),
      child: InkWell(
        onTap: () => context.push(AppRoutes.orderDetailPath(o.id)),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            color: brand.card,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: brand.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                    '#${o.id.substring(0, o.id.length.clamp(0, 8))} · ${Format.date(o.createdAt)}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: brand.textPrimary)),
              ),
              Text(ShopConfig.money(o.total),
                  style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700, color: brand.textPrimary)),
              const SizedBox(width: AppDimens.sm),
              StatusBadge(o.status),
            ],
          ),
        ),
      ),
    );
  }
}

/// Admin management controls: role, per-customer discount, block, notes.
class _AdminControls extends StatefulWidget {
  final UserProfile profile;
  const _AdminControls({required this.profile});

  @override
  State<_AdminControls> createState() => _AdminControlsState();
}

class _AdminControlsState extends State<_AdminControls> {
  late final _discount = TextEditingController(
      text: widget.profile.discountPercent.toStringAsFixed(0));
  late final _notes = TextEditingController(text: widget.profile.adminNotes);

  @override
  void dispose() {
    _discount.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final p = widget.profile;
    final repo = UserRepository.instance;

    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: brand.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: brand.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manage',
              style: AppTextStyles.h3
                  .copyWith(color: brand.textPrimary, fontSize: 16)),
          const SizedBox(height: AppDimens.md),

          // Role
          Text('Role',
              style: AppTextStyles.bodySmall
                  .copyWith(color: brand.textSecondary)),
          const SizedBox(height: 4),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'customer', label: Text('Customer')),
              ButtonSegment(value: 'admin', label: Text('Admin')),
            ],
            selected: {p.isAdmin ? 'admin' : 'customer'},
            onSelectionChanged: (s) async {
              await repo.setRole(p.uid, s.first);
              _toast('Role updated to ${s.first}.');
            },
          ),
          const SizedBox(height: AppDimens.md),

          // Discount
          Text('Loyalty discount (%) — applied to every order',
              style: AppTextStyles.bodySmall
                  .copyWith(color: brand.textSecondary)),
          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _discount,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: const InputDecoration(
                    suffixText: '%',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.sm),
              FilledButton(
                onPressed: () async {
                  final pct =
                      (double.tryParse(_discount.text.trim()) ?? 0).clamp(0, 100);
                  await repo.setDiscount(p.uid, pct.toDouble());
                  _toast('Discount set to ${pct.toStringAsFixed(0)}%.');
                },
                child: const Text('Save'),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),

          // Block
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Block this customer'),
            subtitle: const Text('Blocked customers cannot place orders'),
            value: p.blocked,
            activeThumbColor: AppColors.berry,
            onChanged: (v) async {
              await repo.setBlocked(p.uid, v);
              _toast(v ? 'Customer blocked.' : 'Customer unblocked.');
            },
          ),
          const SizedBox(height: AppDimens.sm),

          // Notes
          Text('Internal notes (admin only)',
              style: AppTextStyles.bodySmall
                  .copyWith(color: brand.textSecondary)),
          const SizedBox(height: 4),
          TextField(
            controller: _notes,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'e.g. wholesale buyer, prefers COD…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppDimens.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                await repo.setNotes(p.uid, _notes.text.trim());
                _toast('Notes saved.');
              },
              icon: const Icon(Icons.save_outlined, size: 18),
              label: const Text('Save notes'),
            ),
          ),
        ],
      ),
    );
  }
}
