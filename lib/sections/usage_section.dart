import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../data/app_content.dart';
import '../widgets/content_cards.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/scroll_reveal.dart';
import '../widgets/section.dart';

class UsageSection extends StatelessWidget {
  const UsageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      background: context.brand.sectionAlt,
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: AppStrings.usageEyebrow,
            title: AppStrings.usageTitle,
            subtitle: AppStrings.usageSubtitle,
          ),
          const SizedBox(height: AppDimens.xxl),
          ScrollReveal(
            child: ResponsiveGrid(
              mobile: 1,
              tablet: 3,
              desktop: 5,
              children:
                  AppContent.usages.map((i) => UsageCard(item: i)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
