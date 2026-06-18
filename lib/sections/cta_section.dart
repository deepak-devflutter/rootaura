import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_gradients.dart';
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
  static const _bg = 'assets/images/CtaSection.png';
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
    return SectionContainer(
      child: ScrollReveal(
        child: isMobile ? _mobile() : _desktop(),
      ),
    );
  }

  // Desktop/tablet: the image is the full banner; content overlays the green
  // text-space on its left.
  Widget _desktop() {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              child: Image.asset(_bg,
                  width: w,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (ctx, e, s) => _fallbackCard(_content(false))),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: w * 0.065),
                  child: SizedBox(width: w * 0.44, child: _content(false)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  // Mobile: like the usage cards — the image fills the card as a cover
  // background with a green scrim so content and photo read together.
  Widget _mobile() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusXl),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(_bg,
                fit: BoxFit.cover,
                errorBuilder: (ctx, e, s) => const SizedBox.shrink()),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.darkGreen.withValues(alpha: 0.4),
                    AppColors.primaryGreen.withValues(alpha: 0.6),
                    AppColors.darkGreen.withValues(alpha: 0.92),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.xl),
            child: _content(true),
          ),
        ],
      ),
    );
  }

  Widget _fallbackCard(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimens.xl),
        decoration: BoxDecoration(
          gradient: AppGradients.forestBand,
          borderRadius: BorderRadius.circular(AppDimens.radiusXl),
        ),
        child: child,
      );

  Widget _content(bool isMobile) {
    final cross =
        isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final align = isMobile ? TextAlign.center : TextAlign.start;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: cross,
      children: [
        Text(AppStrings.ctaTitle,
            textAlign: align,
            style: (isMobile ? AppTextStyles.h1Mobile : AppTextStyles.h1)
                .copyWith(color: Colors.white)),
        const SizedBox(height: AppDimens.sm),
        Text(AppStrings.ctaSubtitle,
            textAlign: align,
            style: AppTextStyles.bodyLarge
                .copyWith(color: Colors.white.withValues(alpha: 0.82))),
        const SizedBox(height: AppDimens.lg),
        _newsletter(),
        const SizedBox(height: AppDimens.md),
        PrimaryButton(
          text: AppStrings.ctaButton,
          icon: Icons.shopping_bag_outlined,
          gold: true,
          onPressed: () => UrlHelper.open(context, AppStrings.amazonUrl),
        ),
      ],
    );
  }

  Widget _newsletter() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Container(
        padding: const EdgeInsets.only(
            left: AppDimens.md, top: 4, bottom: 4, right: 4),
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
}
