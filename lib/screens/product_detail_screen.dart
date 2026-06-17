import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/shop_config.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/product.dart';
import '../data/products_repository.dart';
import '../state/cart_controller.dart';
import '../widgets/app_buttons.dart';
import '../widgets/fruit_art.dart';
import '../widgets/image_carousel.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/qty_stepper.dart';

class ProductDetailScreen extends StatefulWidget {
  final String slug;
  const ProductDetailScreen({super.key, required this.slug});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  Product? _match(List<Product> products) {
    for (final p in products) {
      if (p.slug == widget.slug || p.id == widget.slug) return p;
    }
    return null;
  }

  void _addToCart(Product p) {
    final qty = _qty.clamp(1, p.stock);
    final added = CartController.instance.add(p, qty: qty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(added
            ? '${p.name} (×$qty) added to cart'
            : 'You already have the maximum available (${p.stock}) in your cart'),
        action: added
            ? SnackBarAction(
                label: 'View Cart',
                onPressed: () => context.push(AppRoutes.cart))
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.sectionPaddingH(context),
          vertical: AppDimens.xl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppDimens.maxContentWidth),
            child: StreamBuilder<List<Product>>(
              stream: ProductsRepository.instance.streamActive(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(AppDimens.section),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final product = _match(snap.data ?? const []);
                if (product == null) return _notFound(context);
                return _detail(context, product);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(BuildContext context, Product p) {
    final brand = context.brand;
    final isMobile = Responsive.isMobile(context);

    final image =
        ImageCarousel(imageUrls: p.imageUrls, fallbackAsset: FruitArt.assetFor(p.name));

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _backLink(context),
        const SizedBox(height: AppDimens.md),
        Text(p.name ?? '',
            style: (isMobile ? AppTextStyles.h1Mobile : AppTextStyles.h1)
                .copyWith(color: brand.textPrimary)),
        const SizedBox(height: AppDimens.sm),
        _priceRow(brand, p),
        const SizedBox(height: AppDimens.md),
        Text(p.description ?? '',
            style:
                AppTextStyles.bodyLarge.copyWith(color: brand.textSecondary)),
        const SizedBox(height: AppDimens.lg),
        Container(
          padding: const EdgeInsets.all(AppDimens.md),
          decoration: BoxDecoration(
            color: brand.cardSoft,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primaryGreen),
              const SizedBox(width: AppDimens.sm),
              Expanded(
                child: Text(p.benefit ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.xl),
        if (p.inStock) ...[
          Row(
            children: [
              Text('Quantity',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: brand.textPrimary)),
              const SizedBox(width: AppDimens.md),
              QtyStepper(
                  qty: _qty.clamp(1, p.stock),
                  max: p.stock,
                  onChanged: (q) => setState(() => _qty = q)),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          Wrap(
            spacing: AppDimens.md,
            runSpacing: AppDimens.md,
            children: [
              PrimaryButton(
                text: 'Add to Cart',
                icon: Icons.add_shopping_cart_rounded,
                onPressed: () => _addToCart(p),
              ),
              SecondaryButton(
                text: 'Go to Cart',
                onPressed: () => context.push(AppRoutes.cart),
              ),
            ],
          ),
        ] else
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.md, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.berry.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            ),
            child: Text('Currently out of stock',
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.berry, fontWeight: FontWeight.w600)),
          ),
      ],
    );

    return isMobile
        ? Column(children: [image, const SizedBox(height: AppDimens.xl), info])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 5, child: image),
              const SizedBox(width: AppDimens.xxl),
              Expanded(flex: 6, child: info),
            ],
          );
  }

  Widget _priceRow(BrandColors brand, Product p) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(ShopConfig.money(p.price),
            style: AppTextStyles.h2.copyWith(color: brand.textPrimary)),
        if (p.hasDiscount) ...[
          const SizedBox(width: AppDimens.md),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(ShopConfig.money(p.mrp),
                style: AppTextStyles.bodyLarge.copyWith(
                    color: brand.textSecondary,
                    decoration: TextDecoration.lineThrough)),
          ),
          const SizedBox(width: AppDimens.sm),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('${p.discountPercent}% off',
                style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ],
    );
  }

  Widget _backLink(BuildContext context) {
    return InkWell(
      onTap: () =>
          context.canPop() ? context.pop() : context.go(AppRoutes.products),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_back_rounded,
              size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: 6),
          Text('Back to products',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.primaryGreen)),
        ],
      ),
    );
  }

  Widget _notFound(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.section),
      child: Column(
        children: [
          Text('Product not found',
              style:
                  AppTextStyles.h2.copyWith(color: context.brand.textPrimary)),
          const SizedBox(height: AppDimens.md),
          PrimaryButton(
            text: 'View All Products',
            onPressed: () => context.go(AppRoutes.products),
          ),
        ],
      ),
    );
  }
}
