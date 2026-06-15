
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/app_theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy',
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: 24),
                Text(
                  'Last updated: January 2025',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'At Rootaura Naturals, we respect your privacy and are committed to protecting your personal information. This Privacy Policy outlines how we collect, use, and safeguard your data.',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 24),
                Text(
                  'Information Collection',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We may collect information when you contact us via email or social media. We do not collect payment information as all transactions are processed through Amazon.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  'Contact Us',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'For any privacy-related questions, please contact us at rootaura_naturals@gmail.com',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
