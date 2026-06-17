import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_strings.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/auth_service.dart';
import '../widgets/animated_background.dart';
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
      _confirmation = await AuthService.instance.startPhoneSignIn('+91$digits');
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
    final isWide = Responsive.isDesktop(context);
    return Scaffold(
      body: AnimatedBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.lg),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 920 : 440),
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                  child: isWide
                      ? IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: _BrandPanel()),
                              Expanded(child: _formCard(context)),
                            ],
                          ),
                        )
                      : _formCard(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formCard(BuildContext context) {
    final brand = context.brand;
    return Container(
      padding: const EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        color: brand.card.withValues(alpha: 0.96),
        boxShadow: [
          BoxShadow(color: brand.shadow, blurRadius: 50, offset: const Offset(0, 24)),
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
          Text('Welcome',
              style: AppTextStyles.h1.copyWith(color: brand.textPrimary)),
          const SizedBox(height: 6),
          Text('Sign in to track orders & checkout faster',
              style:
                  AppTextStyles.bodyMedium.copyWith(color: brand.textSecondary)),
          const SizedBox(height: AppDimens.xl),
          if (_error != null) _errorBox(),
          _confirmation == null ? _phoneStep(brand) : _otpStep(brand),
          const SizedBox(height: AppDimens.lg),
          _divider(brand),
          const SizedBox(height: AppDimens.lg),
          _GoogleButton(onPressed: _busy ? null : _google),
        ],
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

/// Branded marketing panel beside the form on wide screens.
class _BrandPanel extends StatelessWidget {
  static const _points = [
    'Track every order in real time',
    'Faster checkout with saved addresses',
    'Member-only offers & loyalty pricing',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkGreen, AppColors.primaryGreen],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.22,
            child: Image.asset(AppAssets.lifestyleBowl, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimens.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(AppStrings.brandName,
                        style: const TextStyle(
                            fontFamily: AppTextStyles.fraunces,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(width: 4),
                    const Icon(Icons.eco_rounded,
                        color: AppColors.softGreen, size: 20),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Real fruit,\npacked with nature.',
                        style: const TextStyle(
                            fontFamily: AppTextStyles.fraunces,
                            fontSize: 32,
                            height: 1.15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(height: AppDimens.lg),
                    ..._points.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: AppDimens.sm),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.gold, size: 18),
                              const SizedBox(width: AppDimens.sm),
                              Expanded(
                                child: Text(p,
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(color: Colors.white70)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
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
