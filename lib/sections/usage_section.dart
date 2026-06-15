
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../widgets/usage_card.dart';

class UsageSection extends StatelessWidget {
  const UsageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final usageIdeas = [
      UsageIdea(
        icon: Icons.local_drink_outlined,
        title: 'Detox Drinks',
        description: 'Quick wellness shots',
      ),
      UsageIdea(
        icon: Icons.soup_kitchen_outlined,
        title: 'Curries & Gravies',
        description: 'Enhance flavor and health naturally',
      ),
      UsageIdea(
        icon: Icons.bakery_dining_outlined,
        title: 'Baking & Snacks',
        description: 'Healthy twist to your treats',
      ),
      UsageIdea(
        icon: Icons.restaurant_menu_outlined,
        title: 'Soups & Salads',
        description: 'Extra nutrition in every bite',
      ),
      UsageIdea(
        icon: Icons.blender_outlined,
        title: 'Smoothies & Juices',
        description: 'Add a nutrient punch to your drinks',
      ),
    ];

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
                'How to Use Rootaura Powders',
                style: isMobile
                    ? AppTextStyles.sectionTitleMobile
                    : AppTextStyles.sectionTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              Wrap(
                spacing: isMobile ? 16 : 32,
                runSpacing: isMobile ? 16 : 32,
                alignment: WrapAlignment.center,
                children: usageIdeas.map((idea) {
                  return UsageCard(idea: idea);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UsageIdea {
  final IconData icon;
  final String title;
  final String description;

  UsageIdea({
    required this.icon,
    required this.title,
    required this.description,
  });
}