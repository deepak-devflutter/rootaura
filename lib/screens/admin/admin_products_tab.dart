import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';
import '../../core/constants/shop_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/product.dart';
import '../../data/products_repository.dart';
import '../../widgets/app_buttons.dart';
import 'product_form_screen.dart';

class AdminProductsTab extends StatelessWidget {
  const AdminProductsTab({super.key});

  Future<void> _openForm(BuildContext context, {Product? existing}) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ProductFormScreen(existing: existing),
    ));
  }

  Future<void> _confirmDelete(BuildContext context, Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('“${p.name}” will be removed from the store.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.berry),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) await ProductsRepository.instance.delete(p.id);
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Products',
                style: AppTextStyles.h3
                    .copyWith(color: brand.textPrimary, fontSize: 18)),
            const Spacer(),
            PrimaryButton(
              text: 'Add Product',
              icon: Icons.add_rounded,
              dense: true,
              onPressed: () => _openForm(context),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.lg),
        StreamBuilder<List<Product>>(
          stream: ProductsRepository.instance.streamAll(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(AppDimens.xxl),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snap.hasError) {
              return Text('Could not load products.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.berry));
            }
            final products = snap.data ?? const [];
            if (products.isEmpty) {
              return Text('No products yet. Tap “Add Product” to create one.',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: brand.textSecondary));
            }
            return Column(
              children: products
                  .map((p) => _ProductRow(
                        product: p,
                        onEdit: () => _openForm(context, existing: p),
                        onDelete: () => _confirmDelete(context, p),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ProductRow(
      {required this.product, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final p = product;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.sm),
      padding: const EdgeInsets.all(AppDimens.sm + 2),
      decoration: BoxDecoration(
        color: brand.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: brand.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            child: Container(
              width: 56,
              height: 56,
              color: brand.cardSoft,
              padding: const EdgeInsets.all(4),
              child: p.firstImage == null
                  ? const Icon(Icons.eco_rounded, color: AppColors.primaryGreen)
                  : CachedNetworkImage(
                      imageUrl: p.firstImage!, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: AppDimens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(p.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: brand.textPrimary)),
                    ),
                    const SizedBox(width: AppDimens.sm),
                    if (!p.active) _tag('Hidden', AppColors.berry),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                    '${ShopConfig.money(p.price)} · ${p.imageUrls.length} image(s)',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: brand.textSecondary)),
              ],
            ),
          ),
          _stockTag(p.stock),
          IconButton(
              tooltip: 'Edit',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 20)),
          IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 20)),
        ],
      ),
    );
  }

  Widget _stockTag(int stock) {
    final color = stock == 0
        ? AppColors.berry
        : (stock < 10 ? AppColors.gold : AppColors.primaryGreen);
    return Container(
      margin: const EdgeInsets.only(right: AppDimens.sm),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(stock == 0 ? 'Out of stock' : '$stock in stock',
          style: AppTextStyles.bodySmall
              .copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }

  Widget _tag(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        ),
        child: Text(text,
            style: AppTextStyles.bodySmall
                .copyWith(color: color, fontWeight: FontWeight.w700)),
      );
}
