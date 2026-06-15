import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';

class StorageSection extends StatelessWidget {
  const StorageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 64,
        vertical: isMobile ? 60 : 80,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppColors.softGreen.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 56,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(height: 24),
              Text(
                'Storage & Safety Guidelines',
                style: isMobile
                    ? AppTextStyles.sectionTitleMobile.copyWith(fontSize: 28)
                    : AppTextStyles.sectionTitle.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _StorageItem(
                icon: Icons.thermostat_outlined,
                text: 'Store in a cool, dry place away from direct sunlight',
              ),
              const SizedBox(height: 20),
              _StorageItem(
                icon: Icons.lock_outline,
                text: 'Keep in an airtight container after opening',
              ),
              const SizedBox(height: 20),
              _StorageItem(
                icon: Icons.cleaning_services_outlined,
                text: 'Always use a clean, dry spoon',
              ),
              const SizedBox(height: 20),
              _StorageItem(
                icon: Icons.ac_unit_outlined,
                text: 'Refrigeration optional for extended shelf life',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StorageItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StorageItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 28,
          color: AppColors.primaryGreen,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}
