import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/app_content.dart';
import '../utils/url_helper.dart';
import '../widgets/app_buttons.dart';
import '../widgets/scroll_reveal.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onExplore;
  const HeroSection({super.key, required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [brand.heroStart, brand.heroEnd],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: _blob(360, AppColors.softGreen.withValues(alpha: 0.18)),
          ),
          Positioned(
            bottom: -160,
            left: -140,
            child: _blob(420, AppColors.gold.withValues(alpha: 0.10)),
          ),
          Positioned(
            top: 120,
            left: 24,
            child: SvgPicture.asset(AppAssets.leafSprig,
                width: 90,
                colorFilter: ColorFilter.mode(
                    AppColors.softGreen.withValues(alpha: 0.5),
                    BlendMode.srcIn)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.sectionPaddingH(context),
              AppDimens.headerHeight + (isMobile ? 32 : 56),
              Responsive.sectionPaddingH(context),
              isMobile ? AppDimens.xxl : AppDimens.section,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: AppDimens.maxContentWidth),
                child: isMobile
                    ? Column(
                        children: [
                          _heroImage(context, true),
                          const SizedBox(height: AppDimens.xl),
                          _copy(context, brand, true),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 5, child: _copy(context, brand, false)),
                          const SizedBox(width: AppDimens.lg),
                          Expanded(flex: 5, child: _heroImage(context, false)),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _copy(BuildContext context, BrandColors brand, bool isMobile) {
    final cross =
        isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final align = isMobile ? TextAlign.center : TextAlign.start;

    return ScrollReveal(
      child: Column(
        crossAxisAlignment: cross,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco_rounded,
                    size: 16, color: AppColors.primaryGreen),
                const SizedBox(width: 6),
                Text(AppStrings.heroBadge,
                    style: AppTextStyles.eyebrow
                        .copyWith(color: AppColors.primaryGreen)),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.lg),
          RichText(
            textAlign: align,
            text: TextSpan(
              style: (isMobile
                      ? AppTextStyles.displayMobile
                      : AppTextStyles.display)
                  .copyWith(color: brand.textPrimary),
              children: [
                TextSpan(text: '${AppStrings.heroTitleLine1}\n'),
                TextSpan(
                  text: AppStrings.heroTitleLine2,
                  style: const TextStyle(color: AppColors.primaryGreen),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.md),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Text(AppStrings.heroSubtitle,
                textAlign: align,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: brand.textSecondary)),
          ),
          const SizedBox(height: AppDimens.lg),
          Wrap(
            spacing: AppDimens.md,
            runSpacing: AppDimens.md,
            alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
            children: [
              PrimaryButton(
                  text: AppStrings.heroCtaPrimary, onPressed: onExplore),
              SecondaryButton(
                text: AppStrings.heroCtaSecondary,
                icon: Icons.shopping_bag_outlined,
                onPressed: () => UrlHelper.open(context, AppStrings.amazonUrl),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.lg),
          _socialProof(brand, isMobile),
          const SizedBox(height: AppDimens.lg),
          _statCards(brand, isMobile),
          const SizedBox(height: AppDimens.lg),
          _miniTrust(brand, isMobile),
        ],
      ),
    );
  }

  Widget _statCards(BrandColors brand, bool isMobile) {
    const stats = [
      (Icons.groups_outlined, '20,000+', 'Happy Customers'),
      (Icons.eco_outlined, '100%', 'Natural & Pure'),
      (Icons.local_florist_outlined, '15+', 'Fruit Varieties'),
    ];
    final cards = stats
        .map((s) => _statCard(brand, s.$1, s.$2, s.$3))
        .toList(growable: false);

    if (isMobile) {
      return Wrap(
        spacing: AppDimens.sm,
        runSpacing: AppDimens.sm,
        alignment: WrapAlignment.center,
        children: cards,
      );
    }
    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: AppDimens.sm),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }

  Widget _statCard(
      BrandColors brand, IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.md, vertical: AppDimens.md),
      decoration: BoxDecoration(
        color: brand.card,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: brand.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: AppColors.primaryGreen),
          const SizedBox(width: AppDimens.sm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: AppTextStyles.h3.copyWith(
                      color: brand.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700)),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: brand.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialProof(BrandColors brand, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(
            5,
            (_) => const Icon(Icons.star_rounded,
                size: 18, color: AppColors.gold)),
        const SizedBox(width: AppDimens.sm),
        Flexible(
          child: Text(AppStrings.heroSocialProof,
              style: AppTextStyles.bodySmall.copyWith(
                  color: brand.textSecondary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _miniTrust(BrandColors brand, bool isMobile) {
    final items = [
      AppContent.whyChoose[1],
      AppContent.whyChoose[0],
      AppContent.whyChoose[5],
    ];
    return Wrap(
      spacing: AppDimens.lg,
      runSpacing: AppDimens.sm,
      alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
      children: items
          .map((i) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 18, color: AppColors.primaryGreen),
                  const SizedBox(width: 6),
                  Text(i.title,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: brand.textPrimary,
                          fontWeight: FontWeight.w600)),
                ],
              ))
          .toList(),
    );
  }

  Widget _heroImage(BuildContext context, bool isMobile) {
    // The realistic photo is self-contained (fruits + leaves baked in), so it
    // gets a large, clean stage aligned to the bottom-right like the reference.
    return ScrollReveal(
      offsetY: 50,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: isMobile ? 360 : 600),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Image.asset(
            AppAssets.heroBowl,
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
