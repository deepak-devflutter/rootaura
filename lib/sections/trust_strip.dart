import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/responsive.dart';
import '../data/app_content.dart';
import '../widgets/content_cards.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/scroll_reveal.dart';

/// A band of four headline trust badges that bridges the hero and the page.
class TrustStrip extends StatelessWidget {
  const TrustStrip({super.key});

  static const _items = [
    InfoItem(Icons.spa_rounded, AppStrings.trust1Title, AppStrings.trust1Sub),
    InfoItem(Icons.ac_unit_rounded, AppStrings.trust2Title, AppStrings.trust2Sub),
    InfoItem(Icons.block_rounded, AppStrings.trust3Title, AppStrings.trust3Sub),
    InfoItem(Icons.favorite_rounded, AppStrings.trust4Title, AppStrings.trust4Sub),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.brand.sectionAlt,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.sectionPaddingH(context),
        vertical: AppDimens.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimens.maxContentWidth),
          child: ScrollReveal(
            child: ResponsiveGrid(
              mobile: 1,
              tablet: 2,
              desktop: 4,
              spacing: AppDimens.md,
              runSpacing: AppDimens.md,
              children: _items.map((i) => TrustPill(item: i)).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
