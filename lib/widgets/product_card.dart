import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/shop_config.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/product.dart';
import '../state/cart_controller.dart';
import 'app_buttons.dart';
import 'fruit_art.dart';
import 'image_carousel.dart';
import 'lift_card.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  void _openDetail(BuildContext c) =>
      c.push(AppRoutes.productDetailPath(product.slug));

  void _addToCart(BuildContext c) {
    final added = CartController.instance.add(product);
    ScaffoldMessenger.of(c).showSnackBar(
      SnackBar(
        content: Text(added
            ? '${product.name} added to cart'
            : 'Only ${product.stock} in stock — already in your cart'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final p = product;
    return LiftCard(
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      padding: EdgeInsets.zero,
      onTap: () => _openDetail(context),
      builder: (context, hovered) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _image(context, hovered),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fraunces,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ).copyWith(color: brand.textPrimary)),
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
                            onPressed: () => _addToCart(context),
                          )
                        : SecondaryButton(
                            text: 'Out of Stock',
                            dense: true,
                            onPressed: () => _openDetail(context),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(BrandColors brand, Product p) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(ShopConfig.money(p.price),
            style: AppTextStyles.price
                .copyWith(color: brand.textPrimary, fontSize: 22)),
        if (p.hasDiscount) ...[
          const SizedBox(width: AppDimens.sm),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(ShopConfig.money(p.mrp),
                style: AppTextStyles.bodySmall.copyWith(
                    color: brand.textSecondary,
                    decoration: TextDecoration.lineThrough)),
          ),
        ],
      ],
    );
  }

  Widget _image(BuildContext context, bool hovered) {
    return Stack(
      children: [
        ImageCarousel(
          imageUrls: product.imageUrls,
          height: 230,
          padding: const EdgeInsets.all(AppDimens.lg),
          fallbackAsset: FruitArt.assetFor(product.name),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusXl),
          ),
        ),
        if (product.hasDiscount)
          Positioned(
            top: AppDimens.md,
            left: AppDimens.md,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.goldSoft,
                borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.5)),
              ),
              child: Text('Save ${product.discountPercent}%',
                  style: AppTextStyles.eyebrow.copyWith(
                      color: AppColors.darkGreen,
                      fontSize: 11,
                      letterSpacing: 0.5)),
            ),
          ),
      ],
    );
  }
}
