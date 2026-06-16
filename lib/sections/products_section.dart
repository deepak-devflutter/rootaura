import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/models/product.dart';
import '../data/products_repository.dart';
import '../widgets/app_buttons.dart';
import '../widgets/product_card.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/scroll_reveal.dart';
import '../widgets/section.dart';

class ProductsSection extends StatelessWidget {
  /// When true, shows every product; otherwise caps the home preview.
  final bool showAll;
  const ProductsSection({super.key, this.showAll = false});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return SectionContainer(
      background: brand.sectionAlt,
      child: Column(
        children: [
          SectionHeader(
            eyebrow: AppStrings.productsEyebrow,
            title: AppStrings.productsTitle,
            subtitle: AppStrings.productsSubtitle,
          ),
          const SizedBox(height: AppDimens.xxl),
          // Live stream so price / stock / out-of-stock reflect in real time.
          StreamBuilder<List<Product>>(
            stream: ProductsRepository.instance.streamActive(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(AppDimens.xxl),
                  child: CircularProgressIndicator(),
                );
              }
              if (snap.hasError) {
                return Text(AppStrings.somethingWrong,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: brand.textSecondary));
              }
              final products = snap.data ?? const [];
              if (products.isEmpty) {
                return Text(AppStrings.noProducts,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: brand.textSecondary));
              }
              final shown =
                  showAll ? products : products.take(6).toList();
              return Column(
                children: [
                  ScrollReveal(
                    child: ResponsiveGrid(
                      mobile: 1,
                      tablet: 2,
                      desktop: 3,
                      children:
                          shown.map((p) => ProductCard(product: p)).toList(),
                    ),
                  ),
                  if (!showAll) ...[
                    const SizedBox(height: AppDimens.xl),
                    SecondaryButton(
                      text: AppStrings.viewAllProducts,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => context.push(AppRoutes.products),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
