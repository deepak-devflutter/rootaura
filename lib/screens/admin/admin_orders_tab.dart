import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/shop_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/order.dart';
import '../../data/order_repository.dart';
import '../../utils/format.dart';
import '../../widgets/status_badge.dart';

/// Order-status groupings used by the admin filter chips.
enum OrderFilter { newOrders, processing, completed, cancelled, all }

extension on OrderFilter {
  String get label => switch (this) {
        OrderFilter.newOrders => 'New',
        OrderFilter.processing => 'Processing',
        OrderFilter.completed => 'Completed',
        OrderFilter.cancelled => 'Cancelled',
        OrderFilter.all => 'All',
      };

  bool matches(String status) => switch (this) {
        OrderFilter.newOrders => status == OrderStatus.placed,
        OrderFilter.processing => const [
            OrderStatus.confirmed,
            OrderStatus.packed,
            OrderStatus.shipped
          ].contains(status),
        OrderFilter.completed => status == OrderStatus.delivered,
        OrderFilter.cancelled => status == OrderStatus.cancelled,
        OrderFilter.all => true,
      };
}

class AdminOrdersTab extends StatefulWidget {
  const AdminOrdersTab({super.key});

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  OrderFilter _filter = OrderFilter.newOrders; // new orders default
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _search,
          onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Search by customer name or order ID',
            prefixIcon: const Icon(Icons.search_rounded),
            isDense: true,
            filled: true,
            fillColor: brand.cardSoft,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.md),
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
            final all = snap.data ?? const [];
            // Count per filter for the chip badges.
            int countFor(OrderFilter f) =>
                all.where((o) => f.matches(o.status)).length;

            final filtered = all.where((o) {
              if (!_filter.matches(o.status)) return false;
              if (_query.isEmpty) return true;
              return o.customerName.toLowerCase().contains(_query) ||
                  o.id.toLowerCase().contains(_query);
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppDimens.sm,
                  children: OrderFilter.values
                      .map((f) => ChoiceChip(
                            label: Text('${f.label} (${countFor(f)})'),
                            selected: _filter == f,
                            onSelected: (_) => setState(() => _filter = f),
                          ))
                      .toList(),
                ),
                const SizedBox(height: AppDimens.md),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.xl),
                    child: Text('No orders here.',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: brand.textSecondary)),
                  )
                else
                  ...filtered.map((o) => _AdminOrderCard(order: o)),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _AdminOrderCard extends StatefulWidget {
  final ShopOrder order;
  const _AdminOrderCard({required this.order});

  @override
  State<_AdminOrderCard> createState() => _AdminOrderCardState();
}

class _AdminOrderCardState extends State<_AdminOrderCard> {
  late final _courier = TextEditingController(text: widget.order.courier);
  late final _tracking = TextEditingController(text: widget.order.trackingId);
  late final _trackingUrl =
      TextEditingController(text: widget.order.trackingUrl);
  bool _savingShipment = false;

  static const _couriers = [
    'Blue Dart',
    'Delhivery',
    'DTDC',
    'India Post',
    'Ekart',
    'XpressBees',
    'Shiprocket',
  ];

  @override
  void dispose() {
    _courier.dispose();
    _tracking.dispose();
    _trackingUrl.dispose();
    super.dispose();
  }

  Future<void> _saveShipment() async {
    if (_courier.text.trim().isEmpty || _tracking.text.trim().isEmpty) {
      _toast('Enter courier and tracking ID.');
      return;
    }
    setState(() => _savingShipment = true);
    try {
      await OrderRepository.instance.updateShipment(
        widget.order.id,
        courier: _courier.text.trim(),
        trackingId: _tracking.text.trim(),
        trackingUrl: _trackingUrl.text.trim().isEmpty
            ? null
            : _trackingUrl.text.trim(),
      );
      _toast('Shipment details saved.');
    } catch (e) {
      _toast('Failed: $e');
    } finally {
      if (mounted) setState(() => _savingShipment = false);
    }
  }

  void _toast(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final o = widget.order;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      decoration: BoxDecoration(
        color: brand.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: brand.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
              horizontal: AppDimens.lg, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(
              AppDimens.lg, 0, AppDimens.lg, AppDimens.lg),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${_shortId(o.id)}  ·  ${o.customerName}',
                        style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: brand.textPrimary)),
                    const SizedBox(height: 2),
                    Text(
                        '${Format.dateTime(o.createdAt)} · ${ShopConfig.money(o.total)} · ${o.paymentMethod.toUpperCase()}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: brand.textSecondary)),
                  ],
                ),
              ),
              StatusBadge(o.status),
            ],
          ),
          children: [
            _kv(brand, 'Phone', o.customerPhone),
            _kv(brand, 'Address', '${o.address.oneLine}\n${o.address.phone}'),
            if (o.upiRef != null) _kv(brand, 'UPI Ref', o.upiRef!),
            if ((o.note ?? '').isNotEmpty) _noteBox(brand, o.note!),
            const SizedBox(height: AppDimens.sm),
            ...o.items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    Expanded(child: Text('${i.name} × ${i.qty}')),
                    Text(ShopConfig.money(i.lineTotal)),
                  ]),
                )),
            const Divider(height: AppDimens.xl),

            // Payment status + rollback
            Row(
              children: [
                StatusBadge(o.paymentStatus, isPayment: true),
                const Spacer(),
                if (o.paymentStatus == PaymentStatus.paid)
                  TextButton.icon(
                    onPressed: () => OrderRepository.instance
                        .setPaymentStatus(o.id, PaymentStatus.pending),
                    icon: const Icon(Icons.undo_rounded, size: 18),
                    label: const Text('Mark not paid'),
                  )
                else
                  TextButton.icon(
                    onPressed: () => OrderRepository.instance
                        .setPaymentStatus(o.id, PaymentStatus.paid),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Mark paid'),
                  ),
              ],
            ),
            const SizedBox(height: AppDimens.sm),

            // Order status
            Row(
              children: [
                Text('Order status:',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: brand.textSecondary)),
                const SizedBox(width: AppDimens.sm),
                DropdownButton<String>(
                  value: o.status,
                  items: [...OrderStatus.flow, OrderStatus.cancelled]
                      .map((s) => DropdownMenuItem(
                          value: s, child: Text(OrderStatus.label(s))))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      OrderRepository.instance.updateStatus(o.id, v);
                    }
                  },
                ),
              ],
            ),
            const Divider(height: AppDimens.xl),

            // Shipment
            Text('Shipment',
                style: AppTextStyles.h3
                    .copyWith(color: brand.textPrimary, fontSize: 15)),
            const SizedBox(height: AppDimens.sm),
            Wrap(
              spacing: AppDimens.sm,
              runSpacing: 4,
              children: _couriers
                  .map((c) => ActionChip(
                        label: Text(c, style: const TextStyle(fontSize: 12)),
                        onPressed: () => setState(() => _courier.text = c),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppDimens.sm),
            _shipField(brand, _courier, 'Courier (e.g. Blue Dart)'),
            _shipField(brand, _tracking, 'Tracking / AWB ID'),
            _shipField(brand, _trackingUrl, 'Tracking URL (optional)'),
            Align(
              alignment: Alignment.centerRight,
              child: _savingShipment
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : TextButton.icon(
                      onPressed: _saveShipment,
                      icon: const Icon(Icons.local_shipping_outlined, size: 18),
                      label: Text(o.hasShipment
                          ? 'Update shipment'
                          : 'Save shipment'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortId(String id) => id.substring(0, id.length.clamp(0, 8));

  Widget _shipField(
      BrandColors brand, TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.sm),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
        ),
      ),
    );
  }

  Widget _noteBox(BrandColors brand, String note) => Container(
        margin: const EdgeInsets.only(top: AppDimens.sm),
        padding: const EdgeInsets.all(AppDimens.sm + 2),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.sticky_note_2_outlined,
                size: 18, color: Color(0xFFB7791F)),
            const SizedBox(width: AppDimens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer note',
                      style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB7791F))),
                  Text(note,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: brand.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      );

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
