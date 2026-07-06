import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_durations.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/app_content.dart';
import '../widgets/brand_icon.dart';
import '../widgets/lift_card.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/section.dart';

class RecipesSection extends StatelessWidget {
  const RecipesSection({super.key});

  @override
  Widget build(BuildContext context) {
    const items = AppContent.recipes;
    return SectionContainer(
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: AppStrings.recipesEyebrow,
            title: AppStrings.recipesTitle,
            subtitle: AppStrings.recipesSubtitle,
          ),
          const SizedBox(height: AppDimens.xxl),
          ResponsiveGrid(
            mobile: 1,
            tablet: 3,
            desktop: 3,
            stagger: true,
            children: [
              for (var i = 0; i < items.length; i++)
                _RecipeCard(
                  item: items[i],
                  onTap: () => _openRecipe(context, items, i),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _openRecipe(BuildContext context, List<RecipeItem> items, int index) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Recipe',
      barrierColor: Colors.black.withValues(alpha: 0.62),
      transitionDuration: AppDurations.medium,
      pageBuilder: (_, __, ___) =>
          _RecipeLightbox(items: items, initialIndex: index),
      transitionBuilder: (c, anim, sec, child) {
        final curved = CurvedAnimation(parent: anim, curve: AppCurves.emphasized);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final RecipeItem item;
  final VoidCallback onTap;
  const _RecipeCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return LiftCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      builder: (context, hovered) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimens.radiusXl)),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.asset(item.image,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Image.asset(
                      'assets/images/basket.webp',
                      fit: BoxFit.cover)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _emojiBadge(item.emoji),
                      const SizedBox(width: AppDimens.sm),
                      Expanded(
                        child: Text(item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.fraunces,
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ).copyWith(color: brand.textPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.md),
                  Wrap(
                    spacing: AppDimens.sm,
                    runSpacing: AppDimens.sm,
                    children: item.ingredients
                        .map((i) => _chip(brand, i))
                        .toList(),
                  ),
                  const Spacer(),
                  const SizedBox(height: AppDimens.md),
                  Row(
                    children: [
                      Text('View recipe',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 4),
                      BrandIcon(BrandIcon.arrowRight,
                          size: 16, color: AppColors.primaryGreen),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emojiBadge(String emoji) => Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.mintTint,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      );

  Widget _chip(BrandColors brand, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: brand.cardSoft,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        ),
        child: Text(text,
            style: AppTextStyles.bodySmall.copyWith(color: brand.textSecondary)),
      );
}

/// Immersive recipe viewer with prev/next navigation.
class _RecipeLightbox extends StatefulWidget {
  final List<RecipeItem> items;
  final int initialIndex;
  const _RecipeLightbox({required this.items, required this.initialIndex});

  @override
  State<_RecipeLightbox> createState() => _RecipeLightboxState();
}

class _RecipeLightboxState extends State<_RecipeLightbox> {
  late int _i = widget.initialIndex;

  void _go(int dir) {
    final n = widget.items.length;
    setState(() => _i = (_i + dir + n) % n);
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final isMobile = Responsive.isMobile(context);
    final r = widget.items[_i];
    final screen = MediaQuery.sizeOf(context);
    final maxH = screen.height * 0.86;

    final image = Image.asset(r.image,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) =>
            Image.asset('assets/images/basket.webp', fit: BoxFit.cover));

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 22, height: 1.5, color: AppColors.gold),
          const SizedBox(width: 8),
          Text('RECIPE',
              style: AppTextStyles.eyebrowGold.copyWith(color: AppColors.gold)),
        ]),
        const SizedBox(height: AppDimens.md),
        Text('${r.emoji}  ${r.title}',
            style: (isMobile ? AppTextStyles.h1Mobile : AppTextStyles.h2)
                .copyWith(color: brand.textPrimary)),
        const SizedBox(height: AppDimens.lg),
        Text('INGREDIENTS',
            style: AppTextStyles.eyebrow
                .copyWith(color: brand.textSecondary, fontSize: 12)),
        const SizedBox(height: AppDimens.sm),
        Wrap(
          spacing: AppDimens.sm,
          runSpacing: AppDimens.sm,
          children: r.ingredients
              .map((i) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: brand.cardSoft,
                      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
                      border: Border.all(color: brand.border),
                    ),
                    child: Text(i,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: brand.textPrimary)),
                  ))
              .toList(),
        ),
        const SizedBox(height: AppDimens.lg),
        Text(
            'Layer it all together and enjoy a wholesome treat made with '
            'real Rootaura freeze-dried fruit.',
            style:
                AppTextStyles.bodyMedium.copyWith(color: brand.textSecondary)),
      ],
    );

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      child: Container(
        color: brand.card,
        child: isMobile
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 240, width: double.infinity, child: image),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimens.xl),
                      child: content,
                    ),
                  ),
                ],
              )
            : SizedBox(
                height: math.min(440, maxH),
                child: Row(
                  children: [
                    Expanded(flex: 5, child: image),
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.xxl),
                        child: Align(
                            alignment: Alignment.centerLeft, child: content),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 880, maxHeight: maxH),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                card,
                Positioned(
                  top: 10,
                  right: 10,
                  child: _circleBtn(BrandIcon.close, () => Navigator.pop(context)),
                ),
                if (widget.items.length > 1) ...[
                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                        child: _circleBtn('chevron-left', () => _go(-1))),
                  ),
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                        child: _circleBtn('chevron-right', () => _go(1))),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusPill),
                        ),
                        child: Text('${_i + 1} / ${widget.items.length}',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _circleBtn(String icon, VoidCallback onTap) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: BrandIcon(icon, size: 20, color: AppColors.darkGreen),
        ),
      ),
    );
  }
}
