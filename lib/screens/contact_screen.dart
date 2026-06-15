import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_colors.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedTopic = 'Product Inquiry';

  final List<String> _topics = [
    'Product Inquiry',
    'Bulk Orders',
    'Export Orders',
    'Partnership',
    'General Question',
    'Feedback',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _getFormattedMessage() {
    return '''Hello Rootaura Naturals,

Topic: $_selectedTopic

Name: ${_nameController.text}
Email: ${_emailController.text}

Message:
${_messageController.text}

---
Sent from Rootaura Naturals Website''';
  }

  Future<void> _sendViaWhatsApp() async {
    if (_formKey.currentState!.validate()) {
      final message = Uri.encodeComponent(_getFormattedMessage());
      final whatsappUrl = 'https://wa.me/918595645501?text=$message';

      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open WhatsApp');
      }
    }
  }

  Future<void> _sendViaEmail() async {
    if (_formKey.currentState!.validate()) {
      final subject = Uri.encodeComponent('Contact: $_selectedTopic');
      final body = Uri.encodeComponent(_getFormattedMessage());
      final emailUrl =
          'mailto:rootaura_naturals@gmail.com?subject=$subject&body=$body';

      final uri = Uri.parse(emailUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackBar('Could not open email client');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 48,
          vertical: 32,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Get in Touch',
                        style: isMobile
                            ? AppTextStyles.sectionTitleMobile
                            : AppTextStyles.sectionTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We\'d love to hear from you. Choose your preferred way to connect.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Form
                Container(
                  padding: const EdgeInsets.all(32),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Field
                        _buildLabel('Your Name'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: _buildInputDecoration('Enter your name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Email Field
                        _buildLabel('Your Email'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          decoration: _buildInputDecoration('Enter your email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Topic Dropdown
                        _buildLabel('Topic'),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedTopic,
                          decoration: _buildInputDecoration('Select a topic'),
                          items: _topics.map((topic) {
                            return DropdownMenuItem(
                              value: topic,
                              child: Text(topic),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTopic = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Message Field
                        _buildLabel('Your Message'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _messageController,
                          decoration: _buildInputDecoration(
                            'Tell us how we can help you...',
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your message';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Submit Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _ContactButton(
                                icon: Icons.phone,
                                label: 'WhatsApp',
                                color: const Color(0xFF25D366),
                                onPressed: _sendViaWhatsApp,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _ContactButton(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                color: AppColors.primaryGreen,
                                onPressed: _sendViaEmail,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Direct Contact Info
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Or reach us directly at:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 18,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'rootaura_naturals@gmail.com',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 18,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+91 8595645501',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.darkGreen,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary.withValues(alpha: 0.5),
        fontSize: 14,
      ),
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.softGreen.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.primaryGreen, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: Icon(widget.icon, size: 20),
          label: Text(widget.label),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isHovered
                ? widget.color.withValues(alpha: 0.9)
                : widget.color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: _isHovered ? 8 : 4,
            shadowColor: widget.color.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
