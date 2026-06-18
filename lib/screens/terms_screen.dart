import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/section.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const String lastUpdated = 'Last updated: 18 June 2026';

  static final List<(String, String)> _sections = [
    (
      '1. Acceptance of Terms',
      'By creating an account, signing in, or placing an order with '
          '${AppStrings.brandName}, you confirm that you have read, understood '
          'and agree to be bound by the most recent version of these Terms & '
          'Conditions. If you do not agree, please do not use the website or '
          'place an order.'
    ),
    (
      '2. Eligibility & Your Account',
      'You must be at least 18 years of age to place an order. You are '
          'responsible for keeping your account credentials and the contact '
          'details on your profile accurate and up to date. You are responsible '
          'for activity that takes place under your account.'
    ),
    (
      '3. Products & Pricing',
      'We sell premium freeze-dried fruit products. Product images are '
          'illustrative; natural colour, size and texture may vary between '
          'batches. All prices are listed in Indian Rupees (₹) and are '
          'inclusive of applicable taxes unless stated otherwise. We may update '
          'prices, offers and product availability at any time without prior '
          'notice.'
    ),
    (
      '4. Orders & Acceptance',
      'Placing an order is an offer to buy. Your order is confirmed only once '
          'we accept it and update its status. We may decline or cancel an '
          'order — for example if an item is out of stock, if there is a '
          'pricing error, or if we cannot deliver to your address — and will '
          'not charge you for a cancelled order.'
    ),
    (
      '5. Payment',
      'We currently accept Cash on Delivery (COD). Please keep the exact order '
          'amount ready at the time of delivery. We reserve the right to limit '
          'COD availability for certain locations or order values, and to '
          'verify orders by phone before dispatch.'
    ),
    (
      '6. Shipping & Delivery',
      'We ship across serviceable pin codes through third-party courier '
          'partners. Delivery timelines are estimates and may be affected by '
          'location, weather or courier delays. A tracking ID is shared once '
          'your order is dispatched. Please ensure someone is available to '
          'receive the order at the provided address.'
    ),
    (
      '7. Cancellations, Returns & Refunds',
      'You may cancel an order from “My Orders” while it is still in the '
          '“placed” stage, before it is confirmed for dispatch. As our products '
          'are perishable food items, we cannot accept returns once delivered. '
          'If you receive a damaged, incorrect or expired product, contact us '
          'at ${AppStrings.contactEmailAddress} within 48 hours of delivery '
          'with photos, and we will arrange a replacement or resolution.'
    ),
    (
      '8. Food Safety & Allergens',
      'Our products are intended as ready-to-eat snacks or ingredients. Please '
          'read the storage guidance and consume before the best-before date. '
          'If you have food allergies, review the product details before '
          'ordering. Store in a cool, dry place and reseal after opening to '
          'preserve crunch and freshness.'
    ),
    (
      '9. Promotions & Loyalty Discounts',
      'Discounts, coupons and account-level loyalty pricing are offered at our '
          'discretion, may have conditions, and may be changed or withdrawn at '
          'any time. They cannot be exchanged for cash.'
    ),
    (
      '10. Intellectual Property',
      'All content on this website — including the ${AppStrings.brandName} '
          'name, logo, text, graphics and product photography — is our property '
          'and may not be copied or used without our written permission.'
    ),
    (
      '11. Limitation of Liability',
      'To the maximum extent permitted by law, our total liability for any '
          'order is limited to the amount paid for that order. We are not '
          'liable for indirect or consequential losses arising from the use of '
          'our products or website.'
    ),
    (
      '12. Privacy',
      'Your personal information is handled in accordance with our Privacy '
          'Policy, which forms part of these Terms.'
    ),
    (
      '13. Changes to These Terms',
      'We may update these Terms from time to time. The version published on '
          'this page is the current one, and continued use of the website or '
          'placing new orders means you accept the latest version.'
    ),
    (
      '14. Governing Law',
      'These Terms are governed by the laws of India. Any disputes are subject '
          'to the exclusive jurisdiction of the courts in our registered '
          'business location.'
    ),
    (
      '15. Contact Us',
      'Questions about these Terms? Write to us at '
          '${AppStrings.contactEmailAddress} and we will be happy to help.'
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
            Text('Terms & Conditions',
                style: AppTextStyles.h1.copyWith(color: brand.textPrimary)),
            const SizedBox(height: AppDimens.sm),
            Text(lastUpdated,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.gold, fontWeight: FontWeight.w600)),
            const SizedBox(height: AppDimens.sm),
            Text(
                'These terms govern your use of ${AppStrings.brandName} and any '
                'orders you place with us. Please read them carefully.',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: brand.textSecondary)),
            const SizedBox(height: AppDimens.xl),
            for (final s in _sections) ...[
              Text(s.$1,
                  style: AppTextStyles.h3.copyWith(color: brand.textPrimary)),
              const SizedBox(height: AppDimens.sm),
              Text(s.$2,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: brand.textSecondary, height: 1.6)),
              const SizedBox(height: AppDimens.lg),
            ],
          ],
        ),
      ),
    );
  }
}
