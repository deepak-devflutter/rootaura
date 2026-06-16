import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/auth_service.dart';
import '../widgets/app_buttons.dart';

class SignInScreen extends StatefulWidget {
  /// Where to return after a successful sign-in.
  final String? from;
  const SignInScreen({super.key, this.from});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();

  ConfirmationResult? _confirmation;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _done() {
    final from = widget.from;
    if (from != null && from.isNotEmpty) {
      context.go(from);
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Authentication failed.');
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() => _run(() async {
        await AuthService.instance.signInWithGoogle();
        if (mounted) _done();
      });

  Future<void> _sendOtp() {
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      setState(() => _error = 'Enter a valid 10-digit mobile number.');
      return Future.value();
    }
    return _run(() async {
      _confirmation =
          await AuthService.instance.startPhoneSignIn('+91$digits');
      setState(() {});
    });
  }

  Future<void> _verifyOtp() {
    if (_otp.text.trim().length < 6) {
      setState(() => _error = 'Enter the 6-digit code.');
      return Future.value();
    }
    return _run(() async {
      await _confirmation!.confirm(_otp.text.trim());
      if (mounted) _done();
    });
  }

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;

    return Scaffold(
      backgroundColor: brand.heroEnd,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(AppDimens.xl),
              decoration: BoxDecoration(
                color: brand.card,
                borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                border: Border.all(color: brand.border),
                boxShadow: [
                  BoxShadow(
                      color: brand.shadow,
                      blurRadius: 40,
                      offset: const Offset(0, 16)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => context.go(AppRoutes.home),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Back to store'),
                    ),
                  ),
                  const SizedBox(height: AppDimens.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.brandName.toUpperCase(),
                          style: AppTextStyles.h2.copyWith(
                              color: AppColors.darkGreen,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(width: 4),
                      const Icon(Icons.eco_rounded,
                          color: AppColors.primaryGreen, size: 22),
                    ],
                  ),
                  const SizedBox(height: AppDimens.sm),
                  Text('Sign in to continue',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: brand.textSecondary)),
                  const SizedBox(height: AppDimens.xl),
                  if (_error != null) _errorBox(),
                  _confirmation == null ? _phoneStep(brand) : _otpStep(brand),
                  const SizedBox(height: AppDimens.lg),
                  _divider(brand),
                  const SizedBox(height: AppDimens.lg),
                  _GoogleButton(onPressed: _busy ? null : _google),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _phoneStep(BrandColors brand) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: _decoration(brand, 'Mobile number', prefix: '+91 '),
        ),
        const SizedBox(height: AppDimens.md),
        _busy
            ? const Center(child: CircularProgressIndicator())
            : PrimaryButton(text: 'Send OTP', onPressed: _sendOtp),
      ],
    );
  }

  Widget _otpStep(BrandColors brand) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Enter the code sent to +91 ${_phone.text}',
            style:
                AppTextStyles.bodySmall.copyWith(color: brand.textSecondary)),
        const SizedBox(height: AppDimens.sm),
        TextField(
          controller: _otp,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: _decoration(brand, '6-digit OTP'),
        ),
        const SizedBox(height: AppDimens.md),
        _busy
            ? const Center(child: CircularProgressIndicator())
            : PrimaryButton(text: 'Verify & Continue', onPressed: _verifyOtp),
        TextButton(
          onPressed: _busy ? null : () => setState(() => _confirmation = null),
          child: const Text('Change number'),
        ),
      ],
    );
  }

  Widget _errorBox() => Container(
        margin: const EdgeInsets.only(bottom: AppDimens.md),
        padding: const EdgeInsets.all(AppDimens.sm + 4),
        decoration: BoxDecoration(
          color: AppColors.berry.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.berry, size: 18),
            const SizedBox(width: AppDimens.sm),
            Expanded(
                child: Text(_error!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.berry))),
          ],
        ),
      );

  Widget _divider(BrandColors brand) => Row(
        children: [
          Expanded(child: Divider(color: brand.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm),
            child: Text('or',
                style: AppTextStyles.bodySmall
                    .copyWith(color: brand.textSecondary)),
          ),
          Expanded(child: Divider(color: brand.border)),
        ],
      );

  InputDecoration _decoration(BrandColors brand, String hint, {String? prefix}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefix,
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
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.6),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _GoogleButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    final brand = context.brand;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: brand.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        ),
      ),
      icon: const Icon(Icons.g_mobiledata_rounded,
          color: AppColors.berry, size: 28),
      label: Text('Continue with Google',
          style: AppTextStyles.button.copyWith(color: brand.textPrimary)),
    );
  }
}
