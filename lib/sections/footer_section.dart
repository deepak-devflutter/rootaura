
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_colors.dart';
import '../core/responsive.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(60),
          topRight: Radius.circular(60),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 64,
        vertical: isMobile ? 48 : 64,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Brand
              Text(
                'Rootaura Naturals',
                style: GoogleFonts.poppins(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.w700,
                  color: AppColors.surface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Colors of Health, Packed with Nature',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.softGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Contact Info
              Wrap(
                spacing: 32,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  _ContactItem(
                    icon: Icons.email_outlined,
                    text: 'rootaura_naturals@gmail.com',
                  ),
                  _ContactItem(
                    icon: Icons.camera_alt_outlined,
                    text: '@rootaura_naturals',
                  ),
                  _ContactItem(
                    icon: Icons.phone_outlined,
                    text: '+91 8595645501',
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Links
              Wrap(
                spacing: 24,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _FooterLink(
                    text: 'Home',
                    onTap: () {
                      Navigator.pushNamed(context, '/');
                    },
                  ),
                  _FooterLink(
                    text: 'Privacy Policy',
                    onTap: () {
                      Navigator.pushNamed(context, '/privacy');
                    },
                  ),
                  _FooterLink(
                    text: 'Contact',
                    onTap: () {
                      Navigator.pushNamed(context, '/contact');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Divider(
                color: AppColors.softGreen.withValues(alpha: 0.3),
                thickness: 1,
              ),
              const SizedBox(height: 24),
              Text(
                '© 2025 Rootaura Naturals. All rights reserved.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.softGreen,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.softGreen,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.surface,
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.surface,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
