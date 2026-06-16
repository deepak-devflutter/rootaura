import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/scroll_reveal.dart';

/// Dark-green band of four brand values with icons.
class ValuesBand extends StatelessWidget {
  const ValuesBand({super.key});

  static const _values = [
    (Icons.eco_rounded, AppStrings.value1Title, AppStrings.value1Sub),
    (Icons.ac_unit_rounded, AppStrings.value2Title, AppStrings.value2Sub),
    (Icons.verified_user_rounded, AppStrings.value3Title, AppStrings.value3Sub),
    (Icons.favorite_rounded, AppStrings.value4Title, AppStrings.value4Sub),
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
              children: _values
                  .map((v) => _value(v.$1, v.$2, v.$3))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _value(IconData icon, String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          ),
          child: Icon(icon, color: AppColors.gold, size: 24),
        ),
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
