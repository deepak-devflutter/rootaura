import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/app_content.dart';
import '../utils/url_helper.dart';

/// Dark-green footer with brand blurb, link columns and a bottom bar.
class AppFooter extends StatelessWidget {
  final void Function(String anchor)? onNavTap;
  const AppFooter({super.key, this.onNavTap});

  void _navTo(BuildContext context, String anchor) {
    if (onNavTap != null) {
      onNavTap!(anchor);
    } else {
      context.go('${AppRoutes.home}?section=$anchor');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      color: AppColors.darkGreen,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.sectionPaddingH(context),
        vertical: AppDimens.xxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimens.maxContentWidth),
          child: Column(
            children: [
              Wrap(
                spacing: AppDimens.xxxl,
                runSpacing: AppDimens.xl,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  SizedBox(width: isMobile ? double.infinity : 340, child: _brand()),
                  _linkColumn(
                    context,
                    AppStrings.footerQuickLinks,
                    AppContent.navLinks
                        .map((l) => _FooterLink(
                            l.label, () => _navTo(context, l.anchor)))
                        .toList(),
                  ),
                  _linkColumn(context, AppStrings.footerContactHead, [
                    _FooterLink(AppStrings.contactEmailAddress,
                        () => UrlHelper.launch('mailto:${AppStrings.contactEmailAddress}')),
                    _FooterLink(AppStrings.contactPhone,
                        () => UrlHelper.launch('tel:${AppStrings.contactPhone}')),
                    _FooterLink(AppStrings.contactPhoneSecondary,
                        () => UrlHelper.launch(
                            'tel:${AppStrings.contactPhoneSecondary}')),
                    _FooterLink('WhatsApp',
                        () => UrlHelper.launch('https://wa.me/${AppStrings.contactPhoneRaw}')),
                    _FooterLink('Instagram',
                        () => UrlHelper.launch(AppStrings.instagramUrl)),
                  ]),
                ],
              ),
              const SizedBox(height: AppDimens.xl),
              Divider(color: Colors.white.withValues(alpha: 0.12)),
              const SizedBox(height: AppDimens.md),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: AppDimens.sm,
                children: [
                  Text(AppStrings.footerRights,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: Colors.white70)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppStrings.footerMadeIn,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white70)),
                      const SizedBox(width: AppDimens.md),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.privacy),
                        child: Text('Privacy Policy',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(AppStrings.brandName.toUpperCase(),
                style: AppTextStyles.h2.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(width: 6),
            const Icon(Icons.eco_rounded, color: AppColors.softGreen, size: 22),
          ],
        ),
        const SizedBox(height: AppDimens.sm),
        Text(AppStrings.brandTagline,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.gold, fontWeight: FontWeight.w600)),
        const SizedBox(height: AppDimens.md),
        Text(AppStrings.footerTagline,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
      ],
    );
  }

  Widget _linkColumn(BuildContext context, String title, List<Widget> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.h3.copyWith(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppDimens.md),
        ...links,
      ],
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _FooterLink(this.label, this.onTap);

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(
            widget.label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: _hover ? AppColors.gold : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
