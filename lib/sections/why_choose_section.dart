import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';

class WhyChooseSection extends StatelessWidget {
  const WhyChooseSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withValues(alpha: 0.05),
            AppColors.background,
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 64,
        vertical: isMobile ? 60 : 100,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Why Choose Rootaura',
                style: isMobile
                    ? AppTextStyles.sectionTitleMobile
                    : AppTextStyles.sectionTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              Wrap(
                spacing:isMobile ? 16 : 32,
                runSpacing: isMobile ? 16 :32,
                alignment: WrapAlignment.center,
                children: [
                  _BenefitCard(
                    icon: Icons.science_outlined,
                    title: 'Advanced Dehydration',
                    description:
                    'Our state-of-the-art dehydration process preserves maximum nutrients while removing moisture, ensuring you get the full benefits of fresh produce.',
                  ),
                  _BenefitCard(
                    icon: Icons.label_outline,
                    title: 'Clean Label',
                    description:
                    '100% pure ingredients with no artificial colors, flavors, or preservatives. What you see is what you get. nothing more, nothing less.',
                  ),
                  _BenefitCard(
                    icon: Icons.schedule_outlined,
                    title: 'Long Shelf Life',
                    description:
                    'Enjoy farm-fresh quality for months without refrigeration. Our natural dehydration process eliminates the need for chemical preservatives.',
                  ),
                  _BenefitCard(
                    icon: Icons.health_and_safety_outlined,
                    title: 'Hygienic Processing',
                    description:
                    'Processed in certified facilities following international food safety standards, ensuring export-grade quality in every batch.',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: 280,
      padding:  EdgeInsets.all(isMobile ? 20 :32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
