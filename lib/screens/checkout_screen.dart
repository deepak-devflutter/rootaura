import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/shop_config.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/address.dart';
import '../data/models/order.dart';
import '../data/models/user_profile.dart';
import '../data/order_repository.dart';
import '../data/products_repository.dart';
import '../data/user_repository.dart';
import '../state/auth_controller.dart';
import '../state/cart_controller.dart';
import '../widgets/address_form.dart';
import '../widgets/order_summary.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/section.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _addressId;
  String _payment = PaymentMethod.cod;
  final _upiRef = TextEditingController();
  final _note = TextEditingController();
  bool _placing = false;

  @override
  void initState() {
    super.initState();
    _addressId = AuthController.instance.profile?.defaultAddress?.id;
  }

  @override
  void dispose() {
    _upiRef.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _addAddress() async {
    final addr = await showAddressSheet(context);
    if (addr == null) return;
    final profile = AuthController.instance.profile;
    if (profile == null) return;
    final updated =
        await UserRepository.instance.upsertAddress(profile, addr);
    AuthController.instance.setProfile(updated);
    setState(() => _addressId = addr.id);
  }

  Address? get _selectedAddress {
    final list = AuthController.instance.profile?.addresses ?? const [];
    for (final a in list) {
      if (a.id == _addressId) return a;
    }
    return list.isNotEmpty ? list.first : null;
  }

  Future<void> _placeOrder() async {
    final cart = CartController.instance;
    final profile = AuthController.instance.profile;
    final address = _selectedAddress;

    if (address == null) {
      _toast('Please add a delivery address.');
      return;
    }
    if (cart.isEmpty || profile == null) return;
    if (profile.blocked) {
      _toast('Your account can’t place orders right now. Please contact us.');
      return;
    }
    if (_payment == PaymentMethod.upi && _upiRef.text.trim().length < 4) {
      _toast('Enter the UPI reference/UTR after paying.');
      return;
    }

    setState(() => _placing = true);
    try {
      final subtotal = cart.subtotal;
      final delivery = ShopConfig.deliveryFor(subtotal);
      final discount =
          OrderSummary.discountFor(subtotal, profile.discountPercent);
      final order = ShopOrder(
        id: '',
        uid: profile.uid,
        customerName: address.name.isNotEmpty ? address.name : profile.name,
        customerPhone: address.phone.isNotEmpty ? address.phone : profile.phone,
        items: cart.items,
        address: address,
        subtotal: subtotal,
        delivery: delivery,
        tax: 0,
        discountPercent: profile.discountPercent,
        discountAmount: discount,
        total: subtotal + delivery - discount,
        paymentMethod: _payment,
        paymentStatus: PaymentStatus.pending,
        status: OrderStatus.placed,
        upiRef: _payment == PaymentMethod.upi ? _upiRef.text.trim() : null,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        createdAt: DateTime.now(),
      );
      final id = await OrderRepository.instance.place(order);
      // Reduce stock atomically; non-fatal if it fails (admin reconciles).
      final items = cart.items;
      try {
        await ProductsRepository.instance.decrementStock(items);
      } catch (_) {}
      cart.clear();
      if (mounted) context.go(AppRoutes.orderSuccessPath(id));
    } catch (e) {
      _toast('Could not place order. Please try again.');
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      ambient: true,
      body: SectionContainer(
        child: ListenableBuilder(
          listenable: Listenable.merge(
              [CartController.instance, AuthController.instance]),
          builder: (context, _) {
            final cart = CartController.instance;
            if (cart.isEmpty) {
              return _emptyState(context);
            }
            final isMobile = Responsive.isMobile(context);
            final profile = AuthController.instance.profile;

            final left = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Checkout',
                    style: AppTextStyles.h1
                        .copyWith(color: context.brand.textPrimary)),
                const SizedBox(height: AppDimens.lg),
                if (profile?.blocked ?? false) _blockedBanner(),
                if (profile?.hasDiscount ?? false) _discountBanner(profile!),
                _addressSection(),
                const SizedBox(height: AppDimens.xl),
                _paymentSection(),
                const SizedBox(height: AppDimens.xl),
                _noteSection(),
              ],
            );

            final right = OrderSummary(
              subtotal: cart.subtotal,
              discountPercent: profile?.discountPercent ?? 0,
              actionLabel: 'Place Order',
              busy: _placing,
              onAction: _placeOrder,
            );

            return isMobile
                ? Column(children: [
                    left,
                    const SizedBox(height: AppDimens.xl),
                    right,
                  ])
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: left),
                      const SizedBox(width: AppDimens.xl),
                      Expanded(flex: 4, child: right),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _noteSection() {
    final brand = context.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Order Note (optional)'),
        TextField(
          controller: _note,
          maxLines: 3,
          maxLength: 300,
          decoration: InputDecoration(
            hintText:
                'Any special request? e.g. delivery instructions, gift note…',
            filled: true,
            fillColor: brand.cardSoft,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimens.md, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              borderSide: BorderSide(color: brand.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              borderSide:
                  const BorderSide(color: AppColors.primaryGreen, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _blockedBanner() => Container(
        margin: const EdgeInsets.only(bottom: AppDimens.md),
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: AppColors.berry.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Row(children: [
          const Icon(Icons.block_rounded, color: AppColors.berry, size: 20),
          const SizedBox(width: AppDimens.sm),
          Expanded(
            child: Text(
                'Your account is currently restricted from placing orders. '
                'Please contact us for help.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.berry)),
          ),
        ]),
      );

  Widget _discountBanner(UserProfile profile) => Container(
        margin: const EdgeInsets.only(bottom: AppDimens.md),
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Row(children: [
          const Icon(Icons.local_offer_outlined,
              color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: AppDimens.sm),
          Expanded(
            child: Text(
                'A ${profile.discountPercent.toStringAsFixed(0)}% loyalty '
                'discount is applied to your order.',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600)),
          ),
        ]),
      );

  Widget _emptyState(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.section),
        child: Center(
          child: Text('Your cart is empty.',
              style: AppTextStyles.h3
                  .copyWith(color: context.brand.textSecondary)),
        ),
      );

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.md),
        child: Text(text,
            style: AppTextStyles.h3
                .copyWith(color: context.brand.textPrimary, fontSize: 18)),
      );

  Widget _addressSection() {
    final addresses = AuthController.instance.profile?.addresses ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Delivery Address'),
        if (addresses.isEmpty)
          _outlineTile(
            icon: Icons.add_location_alt_outlined,
            label: 'Add a delivery address',
            onTap: _addAddress,
          )
        else ...[
          ...addresses.map((a) => _AddressTile(
                address: a,
                selected: a.id == (_selectedAddress?.id),
                onTap: () => setState(() => _addressId = a.id),
              )),
          const SizedBox(height: AppDimens.sm),
          _outlineTile(
            icon: Icons.add_rounded,
            label: 'Add another address',
            onTap: _addAddress,
          ),
        ],
      ],
    );
  }

  Widget _paymentSection() {
    final brand = context.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Payment Method'),
        _PaymentTile(
          selected: _payment == PaymentMethod.cod,
          icon: Icons.payments_outlined,
          title: 'Cash on Delivery',
          subtitle: 'Pay with cash when your order arrives.',
          onTap: () => setState(() => _payment = PaymentMethod.cod),
        ),
        if (ShopConfig.upiEnabled) ...[
          const SizedBox(height: AppDimens.sm),
          _PaymentTile(
            selected: _payment == PaymentMethod.upi,
            icon: Icons.qr_code_2_rounded,
            title: 'UPI (Pay now)',
            subtitle: 'Pay to our UPI ID and enter the reference below.',
            onTap: () => setState(() => _payment = PaymentMethod.upi),
          ),
        ],
        if (ShopConfig.upiEnabled && _payment == PaymentMethod.upi) ...[
          const SizedBox(height: AppDimens.md),
          Container(
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: BoxDecoration(
              color: brand.cardSoft,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Pay to: ',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: brand.textSecondary)),
                    Text(ShopConfig.upiId,
                        style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreen)),
                  ],
                ),
                const SizedBox(height: AppDimens.sm),
                TextField(
                  controller: _upiRef,
                  inputFormatters: [LengthLimitingTextInputFormatter(40)],
                  decoration: InputDecoration(
                    labelText: 'UPI reference / UTR number',
                    filled: true,
                    fillColor: brand.card,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.md, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusMd),
                      borderSide: BorderSide(color: brand.border),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                    'We’ll confirm your payment manually before dispatch.',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: brand.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _outlineTile(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 20),
            const SizedBox(width: AppDimens.sm),
            Text(label,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final Address address;
  final bool selected;
  final VoidCallback onTap;
  const _AddressTile(
      {required this.address, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryGreen.withValues(alpha: 0.06)
                : brand.card,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
                color: selected ? AppColors.primaryGreen : brand.border,
                width: selected ? 1.6 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? AppColors.primaryGreen : brand.textSecondary,
                  size: 20),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(address.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: brand.textPrimary)),
                      const SizedBox(width: AppDimens.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: brand.cardSoft,
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusPill),
                        ),
                        child: Text(address.label,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: brand.textSecondary)),
                      ),
                    ]),
                    const SizedBox(height: 2),
                    Text('${address.oneLine}\n${address.phone}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: brand.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _PaymentTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGreen.withValues(alpha: 0.06)
              : brand.card,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
              color: selected ? AppColors.primaryGreen : brand.border,
              width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? AppColors.primaryGreen : brand.textSecondary),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: brand.textPrimary)),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: brand.textSecondary)),
                ],
              ),
            ),
            Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? AppColors.primaryGreen : brand.textSecondary,
                size: 20),
          ],
        ),
      ),
    );
  }
}
