import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/app_content.dart';
import '../widgets/lift_card.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/scroll_reveal.dart';
import '../widgets/section.dart';

class StorageSection extends StatelessWidget {
  const StorageSection({super.key});

  static const _leaf =
      'assets/product_storage/Vibrant green leaf on transparent background.png';

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      width: double.infinity,
      color: context.brand.sectionAlt,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!isMobile) ..._decorations(),
          SectionContainer(
            child: Column(
              children: [
                const SectionHeader(
                  eyebrow: AppStrings.storageEyebrow,
                  title: AppStrings.storageTitle,
                  subtitle: AppStrings.storageSubtitle,
                ),
                const SizedBox(height: AppDimens.xxl),
                ScrollReveal(
                  child: ResponsiveGrid(
                    mobile: 1,
                    tablet: 2,
                    desktop: 3,
                    children: AppContent.storageTips
                        .map((i) => _StorageCard(item: i))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _decorations() => [
        Positioned(
          top: 34,
          right: -6,
          child: _leafDeco(460),
        ),
        Positioned(
          bottom: -30,
          left: -44,
          child: Transform.rotate(
            angle: 2.4,
            child: _leafDeco(200, opacity: 0.22),
          ),
        ),
      ];

  Widget _leafDeco(double w, {double opacity = 1}) => IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Image.asset(_leaf,
              width: w,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const SizedBox.shrink()),
        ),
      );
}

/// Storage tip card: icon + copy in a left lane, a product photo in a separate
/// right lane — laid out as a Row so text and image can never overlap.
class _StorageCard extends StatelessWidget {
  final InfoItem item;
  const _StorageCard({required this.item});

  static const double _cardHeight = 204;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final radius = BorderRadius.circular(AppDimens.radiusLg);
    return LiftCard(
      padding: EdgeInsets.zero,
      // Softer, warmer card surface so it blends with the section instead of
      // looking starkly white (theme-aware).
      color: brand.translucentSurface,
      builder: (context, hovered) => SizedBox(
        height: _cardHeight,
        child: ClipRRect(
          borderRadius: radius,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Text lane.
              Expanded(
                flex: 54,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppDimens.lg, AppDimens.lg, AppDimens.md, AppDimens.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // _iconBadge(hovered),
                      // const SizedBox(height: AppDimens.md),
                      Text(item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.h3.copyWith(
                              color: brand.textPrimary, fontSize: 17)),
                      const SizedBox(height: AppDimens.sm),
                      // Accent rule under the title (reference styling).
                      Container(
                        width: 30,
                        height: 3,
                        decoration: BoxDecoration(
                          color: brand.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: AppDimens.sm),
                      Text(item.subtitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: brand.textSecondary)),
                    ],
                  ),
                ),
              ),
              // Image lane (clipped to the card; cannot bleed past it).
              Expanded(
                flex: 46,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 220),
                      scale: hovered ? 1.03 : 1.0,
                      // Anchor to the right edge so the photo sits flush with
                      // the card and is fully shown right-to-left.
                      child: Image.asset(
                        item.image,
                        fit: BoxFit.cover,
                        alignment: Alignment.centerRight,
                        errorBuilder: (c, e, s) =>
                            ColoredBox(color: brand.cardSoft),
                      ),
                    ),
                    // Soften the seam where the photo meets the text lane.
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              brand.translucentSurface,
                              brand.translucentSurface.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBadge(bool hovered) {
    final c = hovered ? AppColors.gold : AppColors.primaryGreen;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: (hovered ? AppColors.goldSoft : AppColors.mintTint)
            .withValues(alpha: hovered ? 0.7 : 1),
        shape: BoxShape.circle,
      ),
      child: Icon(item.icon, color: c, size: 22),
    );
  }
}
