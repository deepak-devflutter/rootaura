
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../widgets/buttons.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onExplorePressed;

  const HeroSection({super.key, required this.onExplorePressed});

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
            AppColors.background,
            AppColors.softGreen.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative blob top right
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withValues(alpha: 0.05),
              ),
            ),
          ),
          // Decorative blob bottom left
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.03),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 64,
              vertical: isMobile ? 80 : 120,
            ),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Name
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        'Rootaura Naturals',
                        style: isMobile
                            ? AppTextStyles.heroMobile
                            : AppTextStyles.hero,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tagline
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 1000),
                      child: Text(
                        'Colors of Health, Packed with Nature',
                        style: isMobile
                            ? AppTextStyles.taglineMobile
                            : AppTextStyles.tagline,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Supporting features
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: isMobile ? 8 : 24,
                      runSpacing: 12,
                      children: [
                        _FeaturePill('100% Natural'),
                        _FeaturePill('Farm Fresh'),
                        _FeaturePill('Hygienically Processed'),
                        _FeaturePill('Export Quality'),
                      ],
                    ),
                    const SizedBox(height: 48),
                    // CTAs
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        PrimaryButton(
                          text: 'Explore Products',
                          onPressed: onExplorePressed,
                        ),
                        SecondaryButton(
                          text: 'Buy on Amazon',
                          onPressed: onExplorePressed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String text;

  const _FeaturePill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}
