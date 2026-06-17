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
                          _copy(context, brand, true),
                          const SizedBox(height: AppDimens.xl),
                          _heroImage(context),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 6, child: _copy(context, brand, false)),
                          const SizedBox(width: AppDimens.xxl),
                          Expanded(flex: 5, child: _heroImage(context)),
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
          const SizedBox(height: AppDimens.xl),
          _miniTrust(brand, isMobile),
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

  Widget _heroImage(BuildContext context) {
    return ScrollReveal(
      offsetY: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.gold.withValues(alpha: 0.18),
                Colors.transparent,
              ]),
            ),
            padding: const EdgeInsets.all(AppDimens.lg),
            child: Image.asset(AppAssets.heroBowl, fit: BoxFit.contain),
          ),
          const Positioned(
              top: -14,
              left: -10,
              child: _FloatingFruit('strawberry', size: 66, dy: 12)),
          const Positioned(
              top: 18,
              right: -22,
              child: _FloatingFruit('mango',
                  size: 74, dy: 16, period: Duration(seconds: 6))),
          const Positioned(
              bottom: 6,
              left: -18,
              child: _FloatingFruit('kiwi',
                  size: 60, dy: 14, period: Duration(seconds: 7))),
          const Positioned(
              bottom: -10,
              right: 24,
              child: _FloatingFruit('blueberry',
                  size: 48, dy: 10, period: Duration(seconds: 5))),
          Positioned(
            top: -6,
            right: 8,
            child: SvgPicture.asset(AppAssets.sparkle, width: 24),
          ),
        ],
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

/// A fruit illustration that gently floats up and down (reduced-motion safe).
class _FloatingFruit extends StatefulWidget {
  final String fruit;
  final double size;
  final double dy;
  final Duration period;
  const _FloatingFruit(this.fruit,
      {this.size = 60, this.dy = 12, this.period = const Duration(seconds: 5)});

  @override
  State<_FloatingFruit> createState() => _FloatingFruitState();
}

class _FloatingFruitState extends State<_FloatingFruit>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period);

  @override
  void initState() {
    super.initState();
    _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final img =
        SvgPicture.asset('assets/fruit/${widget.fruit}.svg', width: widget.size);
    if (reduce) return img;
    return AnimatedBuilder(
      animation: CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      builder: (context, child) {
        final v = (_c.value - 0.5) * 2;
        return Transform.translate(
          offset: Offset(0, v * widget.dy),
          child: Transform.rotate(angle: v * 0.05, child: child),
        );
      },
      child: img,
    );
  }
}
