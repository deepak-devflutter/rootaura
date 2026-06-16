import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_durations.dart';
import '../core/constants/shop_config.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/product.dart';
import '../state/cart_controller.dart';
import 'app_buttons.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hover = false;

  void _openDetail() =>
      context.push(AppRoutes.productDetailPath(widget.product.slug));

  void _addToCart() {
    CartController.instance.add(widget.product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.product.name} added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final p = widget.product;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: _openDetail,
        child: AnimatedContainer(
          duration: AppDurations.medium,
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translateByDouble(0.0, _hover ? -10.0 : 0.0, 0.0, 1.0),
          decoration: BoxDecoration(
            color: brand.card,
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            border: Border.all(
                color: _hover
                    ? AppColors.primaryGreen.withValues(alpha: 0.30)
                    : brand.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen
                    .withValues(alpha: _hover ? 0.16 : 0.07),
                blurRadius: _hover ? 40 : 22,
                offset: Offset(0, _hover ? 18 : 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _image(p),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h3
                              .copyWith(color: brand.textPrimary, fontSize: 18)),
                      const SizedBox(height: AppDimens.xs),
                      Text(p.description ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: brand.textSecondary)),
                      const SizedBox(height: AppDimens.md),
                      _priceRow(brand, p),
                      const Spacer(),
                      const SizedBox(height: AppDimens.md),
                      SizedBox(
                        width: double.infinity,
                        child: p.inStock
                            ? PrimaryButton(
                                text: 'Add to Cart',
                                icon: Icons.add_shopping_cart_rounded,
                                dense: true,
                                onPressed: _addToCart,
                              )
                            : SecondaryButton(
                                text: 'Out of Stock',
                                dense: true,
                                onPressed: _openDetail,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(BrandColors brand, Product p) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(ShopConfig.money(p.price),
            style: AppTextStyles.h3
                .copyWith(color: brand.textPrimary, fontSize: 20)),
        if (p.hasDiscount) ...[
          const SizedBox(width: AppDimens.sm),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(ShopConfig.money(p.mrp),
                style: AppTextStyles.bodySmall.copyWith(
                    color: brand.textSecondary,
                    decoration: TextDecoration.lineThrough)),
          ),
          const SizedBox(width: AppDimens.sm),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text('${p.discountPercent}% off',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ],
    );
  }

  Widget _image(Product p) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryGreen.withValues(alpha: 0.07),
                  AppColors.gold.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimens.radiusXl),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: AnimatedScale(
                duration: AppDurations.medium,
                scale: _hover ? 1.06 : 1.0,
                child: CachedNetworkImage(
                  imageUrl: p.firstImage ?? '',
                  fit: BoxFit.contain,
                  placeholder: (c, _) => const Center(
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (c, _, __) => Icon(Icons.eco_rounded,
                      size: 56,
                      color: AppColors.primaryGreen.withValues(alpha: 0.4)),
                ),
              ),
            ),
          ),
          if (p.hasDiscount)
            Positioned(
              top: AppDimens.md,
              left: AppDimens.md,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.berry,
                  borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                ),
                child: Text('${p.discountPercent}% OFF',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11)),
              ),
            ),
        ],
      ),
    );
  }
}
