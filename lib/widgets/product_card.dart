import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'fruit_art.dart';
import 'lift_card.dart';

/// Full-bleed product photo with a frosted-glass info panel over the bottom.
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  static const double _height = 470;
  static const double _panelHeight = 160;
  static const double _overlap = 20;

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
    final p = product;
    return LiftCard(
      onTap: () => _openDetail(context),
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      builder: (context, hovered) => SizedBox(
        height: _height,
        child: Stack(
          children: [
            // Product photo fully visible on top (extends slightly under panel)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _height - _panelHeight + _overlap,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppDimens.radiusXl)),
                child: AnimatedScale(
                  duration: AppDurations.medium,
                  scale: hovered ? 1.05 : 1.0,
                  child: _image(),
                ),
              ),
            ),
            if (p.hasDiscount)
              Positioned(
                top: AppDimens.md,
                left: AppDimens.md,
                child: _saveChip(),
              ),
            // Frosted glass info panel anchored to the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _panelHeight,
              child: _glassPanel(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image() {
    final fruit = FruitArt.assetFor(product.name);
    Widget fallback() => fruit != null
        ? Container(
            color: AppColors.mintTint,
            padding: const EdgeInsets.all(AppDimens.xl),
            child: SvgPicture.asset(fruit, fit: BoxFit.contain),
          )
        : Image.asset('assets/images/basket.png', fit: BoxFit.cover);

    final url = product.firstImage;
    if (url == null || url.isEmpty) return fallback();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (c, _) =>
          Container(color: AppColors.mintTint.withValues(alpha: 0.5)),
      errorWidget: (c, _, __) => fallback(),
    );
  }

  Widget _glassPanel(BuildContext context) {
    final brand = context.brand;
    final p = product;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppDimens.radiusXl)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
              AppDimens.lg, AppDimens.md, AppDimens.lg, AppDimens.lg),
          decoration: BoxDecoration(
            color: brand.translucentSurface,
            border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.25))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.fraunces,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ).copyWith(color: brand.textPrimary)),
              const SizedBox(height: 2),
              Text(p.description ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: brand.textSecondary)),
              const Spacer(),
              Row(
                children: [
                  Expanded(child: _priceRow(brand)),
                  const SizedBox(width: AppDimens.sm),
                  p.inStock
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(BrandColors brand) {
    final p = product;
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

  Widget _saveChip() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.goldSoft,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
        ),
        child: Text('Save ${product.discountPercent}%',
            style: AppTextStyles.eyebrow.copyWith(
                color: AppColors.darkGreen, fontSize: 11, letterSpacing: 0.5)),
      );
}
