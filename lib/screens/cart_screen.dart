import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/shop_config.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/cart_item.dart';
import '../state/cart_controller.dart';
import '../widgets/app_buttons.dart';
import '../widgets/order_summary.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/qty_stepper.dart';
import '../widgets/section.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      ambient: true,
      body: SectionContainer(
        child: ListenableBuilder(
          listenable: CartController.instance,
          builder: (context, _) {
            final cart = CartController.instance;
            if (cart.isEmpty) return const _EmptyCart();
            final isMobile = Responsive.isMobile(context);

            final list = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Cart',
                    style: AppTextStyles.h1
                        .copyWith(color: context.brand.textPrimary)),
                const SizedBox(height: AppDimens.lg),
                ...cart.items.map((i) => _CartRow(item: i)),
              ],
            );

            final summary = OrderSummary(
              subtotal: cart.subtotal,
              actionLabel: 'Proceed to Checkout',
              onAction: () => context.push(AppRoutes.checkout),
            );

            return isMobile
                ? Column(children: [
                    list,
                    const SizedBox(height: AppDimens.xl),
                    summary,
                  ])
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: list),
                      const SizedBox(width: AppDimens.xl),
                      Expanded(flex: 4, child: summary),
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final CartItem item;
  const _CartRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.md),
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: brand.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: brand.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            child: Container(
              width: 64,
              height: 64,
              color: brand.cardSoft,
              padding: const EdgeInsets.all(6),
              child: CachedNetworkImage(
                imageUrl: item.image,
                fit: BoxFit.contain,
                errorWidget: (c, _, __) => const Icon(Icons.eco_rounded,
                    color: AppColors.primaryGreen),
              ),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          // Everything else lives in a flexible column so nothing overflows on
          // narrow phones: title + unit price on top, qty stepper + line total
          // on a second line.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: brand.textPrimary)),
                    ),
                    SizedBox(
                      height: 28,
                      width: 28,
                      child: IconButton(
                        tooltip: 'Remove',
                        padding: EdgeInsets.zero,
                        onPressed: () =>
                            CartController.instance.remove(item.productId),
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                    ),
                  ],
                ),
                Text('${ShopConfig.money(item.price)} each',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: brand.textSecondary)),
                const SizedBox(height: AppDimens.sm),
                Row(
                  children: [
                    QtyStepper(
                      qty: item.qty,
                      max: item.stock,
                      onChanged: (q) =>
                          CartController.instance.setQty(item.productId, q),
                    ),
                    const Spacer(),
                    Text(ShopConfig.money(item.lineTotal),
                        style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: brand.textPrimary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.section),
      child: Column(
        children: [
          SvgPicture.asset('assets/empty/empty-cart.svg', width: 220),
          const SizedBox(height: AppDimens.md),
          Text('Your cart is empty',
              style: AppTextStyles.h2.copyWith(color: brand.textPrimary)),
          const SizedBox(height: AppDimens.sm),
          Text('Add some freeze-dried goodness to get started.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: brand.textSecondary)),
          const SizedBox(height: AppDimens.lg),
          PrimaryButton(
            text: 'Browse Products',
            onPressed: () => context.go(AppRoutes.products),
          ),
        ],
      ),
    );
  }
}
