import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../notifiers/auth_notifier.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isSendingOtp = false;

  Future<void> _handleSendOtp() async {
    if (_phoneController.text.length != 10) return;

    setState(() => _isSendingOtp = true);
    await ref
        .read(authProvider.notifier)
        .checkPhone(_phoneController.text);

    // Temporarily force `true` so the Profile Creation screen always shows for testing!
    // (If the API says `exists` is true, the app normally skips profile creation)
    await _sendFirebaseOtp(true);
  }

  Future<void> _sendFirebaseOtp(bool isNewUser) async {
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
              _isSendingOtp = false;
            });
            context.push('/otp', extra: {
              'verificationId': verificationId,
              'phoneNumber': _phoneController.text,
              'isNewUser': isNewUser,
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (mounted) {
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


  @override
  Widget build(BuildContext context) {


    final authState = ref.watch(authProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: const AssetImage('assets/logo/loginback.png'),
          fit: BoxFit.cover,
          opacity: 0.4,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: _buildPhoneSlide(authState),
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
    ));
  }

  Widget _buildPhoneSlide(AuthState authState) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Image.asset(
            'assets/logo/medy24logo.png',
            height: 160,
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: AppTextStyles.header.copyWith(
                fontSize: 24,
                color: Colors.black,
              ),
              children: const [
                TextSpan(text: 'Welcome to '),
                TextSpan(
                  text: 'Medy24',
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your trusted partner for medicines\ndelivered fast & safely.',
            textAlign: TextAlign.center,
            style: AppTextStyles.description,
          ),
          const SizedBox(height: 24),
          Image.asset(
            'assets/logo/order_medicine.png',
            height: 200,
          ),
          const SizedBox(height: 24),
          Text(
            'Login or Sign up',
            style: AppTextStyles.header.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your mobile number to continue',
            style: AppTextStyles.description,
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Image.asset('assets/logo/india.png', width: 24, height: 24),
                      const SizedBox(width: 8),
                      const Text('+91',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Container(width: 1, height: 24, color: AppColors.divider),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Enter mobile number',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon: Icon(Icons.phone, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (authState.isLoading || _isSendingOtp)
                  ? null
                  : _handleSendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Continue',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_user_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.caption.copyWith(color: Colors.grey),
                  children: [
                    const TextSpan(text: 'By continuing, you agree to our\n'),
                    TextSpan(
                      text: 'Terms',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => context.push('/terms-conditions'),
                    ),
                    const TextSpan(text: ' & '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => context.push('/privacy-policy'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ].animate(interval: 50.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOut),
      ),
    );
  }


}
