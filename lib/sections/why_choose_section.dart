import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/app_content.dart';
import '../widgets/content_cards.dart';
import '../widgets/lift_card.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/scroll_reveal.dart';
import '../widgets/section.dart';

class WhyChooseSection extends StatelessWidget {
  const WhyChooseSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final items = AppContent.whyChoose;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Decorative fruit/leaf imagery that bleeds beyond the section edges.
        if (!isMobile) ..._decorations(),
        SectionContainer(
          child: Column(
            children: [
              _header(context),
              const SizedBox(height: AppDimens.xxl),
              ScrollReveal(
                child: ResponsiveGrid(
                  mobile: 1,
                  tablet: 2,
                  desktop: 3,
                  children: [
                    for (final item in items) _WhyCard(item: item),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.xxl),
              _trustStrip(context),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _decorations() => [
        Positioned(
          top: -12,
          left: -28,
          child: _deco('assets/whyus/whyus_top_left.png', 210),
        ),
        Positioned(
          top: -44,
          right: -16,
          child: _deco('assets/whyus/whyus_top_right.png', 280),
        ),

      ];

  Widget _deco(String asset, double width, {double opacity = 1}) => IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Image.asset(asset,
              width: width,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const SizedBox.shrink()),
        ),
      );

  Widget _header(BuildContext context) {
    final brand = context.brand;
    final isMobile = Responsive.isMobile(context);
    return ScrollReveal(
      child: Column(
        children: [
          _eyebrow(AppStrings.whyEyebrow, brand.accent),
          const SizedBox(height: AppDimens.md),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: (isMobile ? AppTextStyles.h1Mobile : AppTextStyles.h1)
                  .copyWith(color: brand.textPrimary),
              children: const [
                TextSpan(text: 'Goodness you can\n'),
                TextSpan(
                    text: 'taste and trust',
                    style: TextStyle(color: AppColors.primaryGreen)),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(AppStrings.whySubtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: brand.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _eyebrow(String text, Color accent) {
    final line = Container(width: 28, height: 1.5, color: accent);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        line,
        const SizedBox(width: AppDimens.sm + 2),
        Text(text.toUpperCase(),
            style: AppTextStyles.eyebrow
                .copyWith(color: accent, letterSpacing: 2.5)),
        const SizedBox(width: AppDimens.sm + 2),
        line,
      ],
    );
  }

  Widget _trustStrip(BuildContext context) {
    final brand = context.brand;
    const items = [
      (Icons.eco_outlined, '100% Real Fruit'),
      (Icons.science_outlined, 'No Preservatives'),
      (Icons.spa_outlined, 'Nothing Artificial'),
      (Icons.favorite_border_rounded, 'Loved by Thousands'),
    ];
    return ScrollReveal(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppDimens.xl,
        runSpacing: AppDimens.md,
        children: items
            .map((e) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(e.$1, size: 18, color: AppColors.primaryGreen),
                    const SizedBox(width: AppDimens.sm),
                    Text(e.$2,
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: brand.textPrimary,
                            fontWeight: FontWeight.w600)),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

/// "Why us" feature card: icon + copy on the left, a large product photo that
/// overflows the card's top-right corner. On hover the card warms to a
/// cream/gold tint (the reference's highlighted state).
class _WhyCard extends StatelessWidget {
  final InfoItem item;
  const _WhyCard({required this.item});

  static const _cream = Color(0xFFFBF1D9);
  // Fixed height makes every card equal AND lets the IntrinsicHeight grid skip
  // measuring the LayoutBuilder inside (a tight SizedBox answers intrinsics
  // directly instead of descending into it).
  static const double _cardHeight = 222;

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final radius = BorderRadius.circular(AppDimens.radiusLg);
    return LiftCard(
      padding: EdgeInsets.zero,
      builder: (context, hovered) => SizedBox(
        height: _cardHeight,
        child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          // Text occupies the left 60%; image is 50% of card width with 10%
          // of the card width bleeding past the right edge (so 40% sits inside
          // the right) — text and image meet exactly, never overlapping.
          final textWidth = w * 0.60;
          final imageWidth = (w * 0.50).clamp(0.0, 220.0);
          final imageOutside = w * 0.10;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Cream/gold wash that fades in on hover.
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: hovered ? 1 : 0,
                  child: DecoratedBox(
                    decoration:
                        BoxDecoration(color: _cream, borderRadius: radius),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimens.lg),
                child: SizedBox(
                  width: textWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconBadge(item.icon, gold: hovered),
                      const SizedBox(height: AppDimens.md),
                      Text(item.title,
                          style: AppTextStyles.h3.copyWith(
                              color: hovered
                                  ? AppColors.darkGreen
                                  : brand.textPrimary,
                              fontSize: 18)),
                      const SizedBox(height: AppDimens.sm),
                      Text(item.subtitle,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: brand.textSecondary)),
                    ],
                  ),
                ),
              ),
              // Large product photo, bleeds out the top-right corner.
              Positioned(
                top: -26,
                right: -imageOutside,
                child: IgnorePointer(
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 220),
                    scale: hovered ? 1.07 : 1.0,
                    child: Image.asset(
                      item.image,
                      width: imageWidth,
                      height: imageWidth,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}
