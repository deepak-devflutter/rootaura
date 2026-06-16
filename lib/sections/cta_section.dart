import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../utils/url_helper.dart';
import '../widgets/app_buttons.dart';
import '../widgets/scroll_reveal.dart';
import '../widgets/section.dart';

class CtaSection extends StatefulWidget {
  const CtaSection({super.key});

  @override
  State<CtaSection> createState() => _CtaSectionState();
}

class _CtaSectionState extends State<CtaSection> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _subscribe() {
    final value = _email.text.trim();
    final ok = value.contains('@') && value.contains('.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Thanks for subscribing! 🌿'
            : 'Please enter a valid email address.'),
      ),
    );
    if (ok) _email.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final content = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(AppStrings.ctaTitle,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: (isMobile ? AppTextStyles.h1Mobile : AppTextStyles.h1)
                .copyWith(color: Colors.white)),
        const SizedBox(height: AppDimens.sm),
        Text(AppStrings.ctaSubtitle,
            textAlign: isMobile ? TextAlign.center : TextAlign.start,
            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70)),
        const SizedBox(height: AppDimens.lg),
        _newsletter(),
        const SizedBox(height: AppDimens.md),
        PrimaryButton(
          text: AppStrings.ctaButton,
          icon: Icons.shopping_bag_outlined,
          onPressed: () => UrlHelper.open(context, AppStrings.amazonUrl),
        ),
      ],
    );

    return SectionContainer(
      child: ScrollReveal(
        child: Container(
          padding: EdgeInsets.all(isMobile ? AppDimens.lg : AppDimens.xxl),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryGreen, AppColors.darkGreen],
            ),
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 16)),
            ],
          ),
          child: isMobile
              ? Column(children: [_image(), const SizedBox(height: AppDimens.xl), content])
              : Row(
                  children: [
                    Expanded(flex: 6, child: content),
                    const SizedBox(width: AppDimens.xxl),
                    Expanded(flex: 5, child: _image()),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _newsletter() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Container(
        padding: const EdgeInsets.only(left: AppDimens.md, top: 4, bottom: 4, right: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _email,
                onSubmitted: (_) => _subscribe(),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: AppStrings.newsletterHint,
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
            PrimaryButton(
                text: AppStrings.newsletterButton,
                dense: true,
                onPressed: _subscribe),
          ],
        ),
      ),
    );
  }

  Widget _image() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Image.asset(AppAssets.basket, fit: BoxFit.contain),
    );
  }
}
