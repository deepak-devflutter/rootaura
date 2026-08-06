import 'package:flutter/material.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../utils/url_helper.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/section.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  String _topic = 'Product Inquiry';

  final _topics = const [
    'Product Inquiry',
    'Bulk Orders',
    'Export Orders',
    'Partnership',
    'General Question',
    'Feedback',
  ];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  String _composed() => '''Hello Rootaura Naturals,

Topic: $_topic

Name: ${_name.text}
Email: ${_email.text}

Message:
${_message.text}

---
Sent from the Rootaura Naturals website''';

  void _sendWhatsApp() {
    if (_formKey.currentState!.validate()) {
      final msg = Uri.encodeComponent(_composed());
      UrlHelper.launch(
          'https://wa.me/${AppStrings.contactPhoneRaw}?text=$msg');
    }
  }

  void _sendEmail() {
    if (_formKey.currentState!.validate()) {
      final subject = Uri.encodeComponent('Contact: $_topic');
      final body = Uri.encodeComponent(_composed());
      UrlHelper.launch(
          'mailto:${AppStrings.contactEmailAddress}?subject=$subject&body=$body');
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    final isMobile = Responsive.isMobile(context);

    return PageScaffold(
      body: SectionContainer(
        maxWidth: 720,
        child: Column(
          children: [
            const SectionHeader(
              eyebrow: 'Contact Us',
              title: AppStrings.contactTitle,
              subtitle: AppStrings.contactSubtitle,
            ),
            const SizedBox(height: AppDimens.xxl),
            Container(
              padding: EdgeInsets.all(isMobile ? AppDimens.lg : AppDimens.xl),
              decoration: BoxDecoration(
                color: brand.card,
                borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                border: Border.all(color: brand.border),
                boxShadow: [
                  BoxShadow(
                      color: brand.shadow,
                      blurRadius: 30,
                      offset: const Offset(0, 12)),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _field(AppStrings.contactName, _name, 'Enter your name'),
                    _field(AppStrings.contactEmail, _email, 'Enter your email',
                        email: true),
                    _label(AppStrings.contactTopic),
                    DropdownButtonFormField<String>(
                      initialValue: _topic,
                      decoration: _decoration('Select a topic'),
                      items: _topics
                          .map((t) =>
                              DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => setState(() => _topic = v!),
                    ),
                    const SizedBox(height: AppDimens.lg),
                    _field(AppStrings.contactMessage, _message,
                        'Tell us how we can help…',
                        maxLines: 5),
                    Row(
                      children: [
                        Expanded(
                          child: _ContactButton(
                            icon: Icons.chat_rounded,
                            label: AppStrings.contactWhatsApp,
                            color: const Color(0xFF25D366),
                            onPressed: _sendWhatsApp,
                          ),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: _ContactButton(
                            icon: Icons.email_rounded,
                            label: AppStrings.contactEmailBtn,
                            color: AppColors.primaryGreen,
                            onPressed: _sendEmail,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimens.xl),
            _directContact(brand),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: AppDimens.sm),
        child: Text(text,
            style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: context.brand.textPrimary)),
      );

  Widget _field(String label, TextEditingController c, String hint,
      {bool email = false, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextFormField(
          controller: c,
          maxLines: maxLines,
          keyboardType:
              email ? TextInputType.emailAddress : TextInputType.text,
          decoration: _decoration(hint),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'This field is required';
            if (email && !v.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: AppDimens.lg),
      ],
    );
  }

  InputDecoration _decoration(String hint) {
    final brand = context.brand;
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium
          .copyWith(color: brand.textSecondary.withValues(alpha: 0.6)),
      filled: true,
      fillColor: brand.cardSoft,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide: BorderSide(color: brand.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        borderSide:
            const BorderSide(color: AppColors.primaryGreen, width: 1.6),
      ),
    );
  }

  Widget _directContact(BrandColors brand) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        children: [
          Text(AppStrings.contactDirect,
              style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600, color: brand.textPrimary)),
          const SizedBox(height: AppDimens.md),
          _contactRow(Icons.email_outlined, AppStrings.contactEmailAddress,
              'mailto:${AppStrings.contactEmailAddress}'),
          const SizedBox(height: AppDimens.sm),
          _contactRow(Icons.phone_outlined, AppStrings.contactPhone,
              'tel:${AppStrings.contactPhone}'),
          const SizedBox(height: AppDimens.sm),
          _contactRow(Icons.phone_outlined, AppStrings.contactPhoneSecondary,
              'tel:${AppStrings.contactPhoneSecondary}'),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text, String url) {
    return InkWell(
      onTap: () => UrlHelper.launch(url),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryGreen),
          const SizedBox(width: AppDimens.sm),
          Text(text,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: context.brand.textSecondary)),
        ],
      ),
    );
  }
}

class _ContactButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_ContactButton> createState() => _ContactButtonState();
}

class _ContactButtonState extends State<_ContactButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color:
                _hover ? widget.color.withValues(alpha: 0.9) : widget.color,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            boxShadow: [
              BoxShadow(
                  color: widget.color.withValues(alpha: _hover ? 0.4 : 0.25),
                  blurRadius: _hover ? 18 : 10,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: AppDimens.sm),
              Text(widget.label,
                  style: AppTextStyles.button.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
