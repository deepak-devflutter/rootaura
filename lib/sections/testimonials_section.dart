import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../data/app_content.dart';
import '../widgets/content_cards.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/scroll_reveal.dart';
import '../widgets/section.dart';

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      child: Column(
        children: [
          const SectionHeader(
            eyebrow: AppStrings.testimonialsEyebrow,
            title: AppStrings.testimonialsTitle,
          ),
          const SizedBox(height: AppDimens.xxl),
          ScrollReveal(
            child: ResponsiveGrid(
              mobile: 1,
              tablet: 3,
              desktop: 3,
              children: AppContent.testimonials
                  .map((t) => TestimonialCard(item: t))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
