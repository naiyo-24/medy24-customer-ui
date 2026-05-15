import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:go_router/go_router.dart';
import '../../cards/auth/contact_bottomsheet.dart';
import '../../notifiers/auth_notifier.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  bool _isSendingOtp = false;

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleSendOtp() async {
    if (_phoneController.text.length != 10) return;

    setState(() => _isSendingOtp = true);
    final exists = await ref
        .read(authProvider.notifier)
        .checkPhone(_phoneController.text);

    if (exists) {
      await _sendFirebaseOtp();
    } else {
      setState(() => _isSendingOtp = false);
      if (mounted) {
        context.push('/signup/${_phoneController.text}');
      }
    }
  }

  Future<void> _sendFirebaseOtp() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${_phoneController.text}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-resolution
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            setState(() => _isSendingOtp = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification Failed: ${e.message}')),
            );
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _isSendingOtp = false;
            });
            _nextPage();
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (mounted) {
            _verificationId = verificationId;
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingOtp = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.length != 6 || _verificationId == null) return;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        final success = await ref
            .read(authProvider.notifier)
            .verifyOtp(token: idToken, phoneNumber: _phoneController.text);
        if (success && mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.user != null) {
        context.go('/home');
      }
    });

    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPhoneSlide(authState),
                    _buildOtpSlide(authState),
                  ],
                ),
              ),
              if (authState.isLoading || _isSendingOtp)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneSlide(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STEP 1 OF 2',
          style: AppTextStyles.tagline.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 12),
        Text(
          'Your wellness journey\nstarts here',
          style: AppTextStyles.header.copyWith(height: 1.1, letterSpacing: -1),
        ),
        const SizedBox(height: 12),
        const Text(
          'Join Medy24 today. Your health and convenience are just a phone number away.',
          style: AppTextStyles.description,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo/india.png',
                    width: 24,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Iconsax.call),
                  ),
                  const SizedBox(width: 8),
                  const Text('+91', style: AppTextStyles.description),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.description.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter phone number',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (authState.isLoading || _isSendingOtp)
                ? null
                : _handleSendOtp,
            child: const Text('Send OTP'),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.caption,
              children: [
                const TextSpan(text: 'By signing in, you agree to our\n'),
                TextSpan(
                  text: 'terms and conditions',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => context.go('/terms-conditions'),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'privacy policies',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => context.go('/privacy-policy'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOtpSlide(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _previousPage,
          child: Row(
            children: [
              const Icon(
                Iconsax.arrow_left_2,
                size: 22,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Go back',
                style: AppTextStyles.tagline.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('FINAL STEP', style: AppTextStyles.tagline.copyWith(fontSize: 12)),
        const SizedBox(height: 12),
        Text(
          'Secure\nVerification',
          style: AppTextStyles.header.copyWith(height: 1.1, letterSpacing: -1),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: AppTextStyles.description,
            children: [
              const TextSpan(text: 'We\'ve sent a unique code to '),
              TextSpan(
                text: '+91 ${_phoneController.text}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const TextSpan(text: '. Enter it below to continue.'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Pinput(
          length: 6,
          controller: _otpController,
          defaultPinTheme: PinTheme(
            width: 64,
            height: 84,
            textStyle: AppTextStyles.header.copyWith(fontSize: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
          ),
          focusedPinTheme: PinTheme(
            width: 64,
            height: 84,
            textStyle: AppTextStyles.header.copyWith(fontSize: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (authState.isLoading || _isSendingOtp)
                ? null
                : _handleVerifyOtp,
            child: const Text('Verify and Login'),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.caption,
              children: [
                const TextSpan(text: "Didn't receive the otp? "),
                TextSpan(
                  text: 'Resend',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Contact Support',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _showContactBottomSheet(context);
                    },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showContactBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const ContactBottomSheet(),
    );
  }
}
