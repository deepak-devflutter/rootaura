import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../widgets/scroll_reveal.dart';
import '../widgets/section.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final isMobile = Responsive.isMobile(context);

    final image = ScrollReveal(
      offsetY: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        child: AspectRatio(
          aspectRatio: 1.05,
          child: Image.asset(AppAssets.lifestyleBowl, fit: BoxFit.fitHeight),
        ),
      ),
    );

    final text = ScrollReveal(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _eyebrow(AppStrings.aboutEyebrow),
          const SizedBox(height: AppDimens.md),
          Text(AppStrings.aboutTitle,
              style: (isMobile ? AppTextStyles.h1Mobile : AppTextStyles.h1)
                  .copyWith(color: brand.textPrimary)),
          const SizedBox(height: AppDimens.md),
          Text(AppStrings.aboutBody1,
              style:
                  AppTextStyles.bodyLarge.copyWith(color: brand.textSecondary)),
          const SizedBox(height: AppDimens.md),
          Text(AppStrings.aboutBody2,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: brand.textSecondary)),
          const SizedBox(height: AppDimens.lg),
          _promiseBox(brand),
        ],
      ),
    );

    return SectionContainer(
      child: isMobile
          ? Column(children: [image, const SizedBox(height: AppDimens.xl), text])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: image),
                const SizedBox(width: AppDimens.xxl),
                Expanded(flex: 6, child: text),
              ],
            ),
    );
  }

  Widget _eyebrow(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        ),
        child: Text(text.toUpperCase(),
            style:
                AppTextStyles.eyebrow.copyWith(color: AppColors.primaryGreen)),
      );

  Widget _promiseBox(BrandColors brand) => Container(
        padding: const EdgeInsets.all(AppDimens.lg),
        decoration: BoxDecoration(
          color: brand.cardSoft,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border(
            left: BorderSide(color: AppColors.primaryGreen, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.aboutPromiseTitle,
                style: AppTextStyles.h3
                    .copyWith(color: AppColors.primaryGreen, fontSize: 18)),
            const SizedBox(height: AppDimens.sm),
            Text(AppStrings.aboutPromiseBody,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: brand.textSecondary)),
          ],
        ),
      );
}
