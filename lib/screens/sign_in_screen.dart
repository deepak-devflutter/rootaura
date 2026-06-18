import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

          // Primary path: Google (fastest, no SMS cost).
          _GoogleButton(busy: _busy, onPressed: _busy ? null : _google),
          const SizedBox(height: AppDimens.sm),
          Center(
            child: Text('Fastest sign-in — no OTP needed',
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: AppDimens.lg),
          _divider(brand, 'or use your phone'),
          const SizedBox(height: AppDimens.lg),

          // Secondary path: phone OTP.
          _confirmation == null ? _phoneStep(brand) : _otpStep(brand),
          const SizedBox(height: AppDimens.lg),
          _legalNotice(context, brand),
        ],
      ),
    );
  }

  Widget _legalNotice(BuildContext context, BrandColors brand) {
    final base =
        AppTextStyles.bodySmall.copyWith(color: brand.textSecondary, fontSize: 12);
    final link = base.copyWith(
        color: AppColors.primaryGreen, fontWeight: FontWeight.w700);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('By continuing you agree to our ', style: base),
        InkWell(
          onTap: () => context.push(AppRoutes.terms),
          child: Text('Terms & Conditions', style: link),
        ),
        Text(' and ', style: base),
        InkWell(
          onTap: () => context.push(AppRoutes.privacy),
          child: Text('Privacy Policy', style: link),
        ),
        Text('.', style: base),
      ],
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
            : SecondaryButton(
                text: 'Send OTP',
                icon: Icons.sms_outlined,
                onPressed: _sendOtp),
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

  Widget _divider(BrandColors brand, String label) => Row(
        children: [
          Expanded(child: Divider(color: brand.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm),
            child: Text(label,
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

/// The official multi-colour Google "G", inlined so it needs no asset.
const String _googleG = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
<path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
<path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
<path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
<path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
</svg>''';

/// Primary, prominent white Google sign-in button (the recommended path).
class _GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool busy;
  const _GoogleButton({this.onPressed, this.busy = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: Container(
          height: 56,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
            border: Border.all(color: const Color(0xFFDADCE0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4))
              else
                SvgPicture.string(_googleG, width: 22, height: 22),
              const SizedBox(width: AppDimens.md),
              Text('Continue with Google',
                  style: AppTextStyles.button.copyWith(
                      color: const Color(0xFF1F1F1F),
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
