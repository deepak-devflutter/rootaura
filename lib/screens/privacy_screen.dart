import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/section.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _sections = [
    (
      'Information We Collect',
      'When you contact us or subscribe, we may collect your name, email '
          'address and any message you send. We do not collect payment '
          'information — purchases are completed on third-party marketplaces.'
    ),
    (
      'How We Use Your Information',
      'We use your information only to respond to enquiries, process requests, '
          'and — with your consent — share product updates and offers.'
    ),
    (
      'Cookies & Analytics',
      'Our website may use basic analytics to understand how visitors use the '
          'site so we can improve it. No personally identifying data is sold.'
    ),
    (
      'Third-Party Links',
      'Our site links to external marketplaces such as Amazon. Their privacy '
          'practices are governed by their own policies.'
    ),
    (
      'Your Choices',
      'You can ask us to access, update or delete your information at any time '
          'by writing to ${AppStrings.contactEmailAddress}.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return PageScaffold(
      body: SectionContainer(
        maxWidth: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.privacyTitle,
                style: AppTextStyles.h1.copyWith(color: brand.textPrimary)),
            const SizedBox(height: AppDimens.sm),
            Text(
                'Your trust matters to us. This policy explains how Rootaura '
                'Naturals handles your information.',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: brand.textSecondary)),
            const SizedBox(height: AppDimens.xl),
            for (final s in _sections) ...[
              Text(s.$1,
                  style: AppTextStyles.h3.copyWith(color: brand.textPrimary)),
              const SizedBox(height: AppDimens.sm),
              Text(s.$2,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: brand.textSecondary)),
              const SizedBox(height: AppDimens.lg),
            ],
          ],
        ),
      ),
    );
  }
}
