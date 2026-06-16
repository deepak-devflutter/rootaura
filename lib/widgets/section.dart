import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import 'scroll_reveal.dart';

/// A page section with consistent vertical rhythm, max width and optional
/// background. Use [background] to alternate bands down the page.
class SectionContainer extends StatelessWidget {
  final Widget child;
  final Color? background;
  final Gradient? gradient;
  final double maxWidth;

  const SectionContainer({
    super.key,
    required this.child,
    this.background,
    this.gradient,
    this.maxWidth = AppDimens.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: background, gradient: gradient),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.sectionPaddingH(context),
        vertical: Responsive.sectionPaddingV(context),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Centered eyebrow + title + subtitle block used at the top of most sections.
class SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final CrossAxisAlignment align;
  final TextAlign textAlign;

  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.align = CrossAxisAlignment.center,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final isMobile = Responsive.isMobile(context);

    return ScrollReveal(
      child: Column(
        crossAxisAlignment: align,
        children: [
          _EyebrowChip(text: eyebrow),
          const SizedBox(height: AppDimens.md),
          Text(
            title,
            textAlign: textAlign,
            style: (isMobile ? AppTextStyles.h1Mobile : AppTextStyles.h1)
                .copyWith(color: brand.textPrimary),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppDimens.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Text(
                subtitle!,
                textAlign: textAlign,
                style: AppTextStyles.bodyLarge
                    .copyWith(color: brand.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EyebrowChip extends StatelessWidget {
  final String text;
  const _EyebrowChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.eyebrow.copyWith(color: AppColors.primaryGreen),
      ),
    );
  }
}
