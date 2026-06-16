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

class ProductsSection extends StatefulWidget {
  /// When true, shows every product; otherwise caps the home preview.
  final bool showAll;
  const ProductsSection({super.key, this.showAll = false});

  @override
  State<ProductsSection> createState() => _ProductsSectionState();
}

class _ProductsSectionState extends State<ProductsSection> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = ProductsRepository.instance.load();
  }

  void _retry() => setState(
      () => _future = ProductsRepository.instance.load(forceRefresh: true));

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
          FutureBuilder<List<Product>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(AppDimens.xxl),
                  child: CircularProgressIndicator(),
                );
              }
              if (snap.hasError) return _error();
              final products = snap.data ?? const [];
              if (products.isEmpty) {
                return Text(AppStrings.noProducts,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: brand.textSecondary));
              }
              final shown =
                  widget.showAll ? products : products.take(6).toList();
              return Column(
                children: [
                  ScrollReveal(
                    child: ResponsiveGrid(
                      mobile: 1,
                      tablet: 2,
                      desktop: 3,
                      children: shown
                          .map((p) => ProductCard(product: p))
                          .toList(),
                    ),
                  ),
                  if (!widget.showAll) ...[
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

  Widget _error() {
    return Column(
      children: [
        Text(AppStrings.somethingWrong,
            style: AppTextStyles.bodyLarge
                .copyWith(color: context.brand.textSecondary)),
        const SizedBox(height: AppDimens.md),
        PrimaryButton(text: AppStrings.tryAgain, onPressed: _retry),
      ],
    );
  }
}
