import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/scroll_reveal.dart';

/// Dark-green band of four brand values, each led by a luxury trust seal.
class ValuesBand extends StatelessWidget {
  const ValuesBand({super.key});

  static const _values = [
    ('assets/badges/farm-fresh.svg', AppStrings.value1Title, AppStrings.value1Sub),
    ('assets/badges/freeze-dried.svg', AppStrings.value2Title, AppStrings.value2Sub),
    ('assets/badges/natural-100.svg', AppStrings.value3Title, AppStrings.value3Sub),
    ('assets/badges/made-in-india.svg', AppStrings.value4Title, AppStrings.value4Sub),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkGreen, AppColors.primaryGreen],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.sectionPaddingH(context),
        vertical: AppDimens.xxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimens.maxContentWidth),
          child: ScrollReveal(
            child: ResponsiveGrid(
              mobile: 1,
              tablet: 2,
              desktop: 4,
              spacing: AppDimens.xl,
              runSpacing: AppDimens.xl,
              children: _values.map((v) => _value(v.$1, v.$2, v.$3)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _value(String badge, String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(badge, width: 64, height: 64),
        const SizedBox(height: AppDimens.md),
        Text(title,
            style: AppTextStyles.h3.copyWith(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppDimens.xs + 2),
        Text(sub,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
      ],
    );
  }
}
