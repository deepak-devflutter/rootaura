
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
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
                'About Rootaura',
                style: isMobile
                    ? AppTextStyles.sectionTitleMobile
                    : AppTextStyles.sectionTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      // 'At Rootaura Naturals, we believe that good health begins with nature. Our mission is to bring you pure, natural, and nutrient-rich dehydrated vegetables and fruit powders, carefully processed to retain their natural goodness.',
                     'At Rootaura, we believe healthy snacking should be natural, convenient, and delicious. Our mission is to bring the goodness of real fruits to modern lifestyles through advanced freeze-drying technology.',
                      style: AppTextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      // 'From farm-fresh produce to convenient powders, we make healthy eating simple — whether for home kitchens, restaurants, or export needs.',
                     'We carefully select premium fruits and freeze-dry them to preserve their natural taste, vibrant color, and essential nutrients, without adding preservatives or artificial ingredients. The result is a light, crunchy snack that delivers real fruit goodness in every bite.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),   const SizedBox(height: 32),
                    Text(
                      'Whether you\'re at work, traveling, exercising, or simply looking for a healthier snack option, Rootaura makes it easy to enjoy nature\'s nutrition anytime, anywhere.',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    // Advantages Grid
                    Wrap(
                      spacing: isMobile ? 16 : 32,
                      runSpacing: isMobile ? 16 : 32,
                      alignment: WrapAlignment.center,
                      children: [
                        _AdvantageCard(
                          icon: Icons.verified_outlined,
                          titleIcon: '🍓',
                          title: '100% Real Fruit',
                          description: 'Made from carefully selected fruits with nothing artificial.',
                        ),
                        _AdvantageCard(
                          icon: Icons.energy_savings_leaf_outlined,
                          titleIcon: '❄️',
                          title: 'Freeze-Dried Technology',
                          description: 'Preserves flavor, texture, and nutrients naturally.',
                        ),
                        _AdvantageCard(
                          icon: Icons.restaurant_outlined,
                          titleIcon: '🌿',
                          title: 'No Preservatives',
                          description: 'Clean-label snacks with no artificial additives.',
                        ),
                        _AdvantageCard(
                          icon: Icons.eco_outlined,
                          titleIcon: '❤️',
                          title: 'Healthy & Convenient',
                          description: 'Perfect for modern, on-the-go lifestyles.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdvantageCard extends StatelessWidget {
  final IconData icon;
  final String titleIcon;
  final String title;
  final String description;

  const _AdvantageCard({
    required this.icon,
    required this.titleIcon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.softGreen.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Icon(
          //   icon,
          //   size: 48,
          //   color: AppColors.primaryGreen,
          // ),
          Text(titleIcon,style: TextStyle(fontWeight: FontWeight.w600, fontSize: 50),),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
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
