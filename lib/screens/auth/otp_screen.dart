import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final bool isNewUser;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.isNewUser,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  int _timerSeconds = 25;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timerSeconds = 25;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timerSeconds == 0) {
        timer.cancel();
        setState(() {}); // trigger rebuild to show Resend text
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.length != 6) return;

    setState(() => _isVerifying = true);

    // DEMO BYPASS: If OTP is 000000, bypass Firebase and Backend
    if (_otpController.text == '000000') {
      await ref.read(authProvider.notifier).demoLogin(widget.phoneNumber);
      if (mounted) {
        if (widget.isNewUser) {
          context.go('/profile-creation');
        } else {
          context.go('/home');
        }
      }
      return;
    }

    try {
      /*
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _otpController.text,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
      */
        // Use our APITxT OTP verification endpoint instead of Firebase
        final success = await ref
            .read(authProvider.notifier)
            .verifyOtp(token: _otpController.text, phoneNumber: '+91${widget.phoneNumber}');
            
        if (success && mounted) {
          if (widget.isNewUser) {
            context.go('/profile-creation');
          } else {
            context.go('/home');
          }
        } else if (!success && mounted) {
          final errorMsg = ref.read(authProvider).error ?? 'Server verification failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      /*
      }
      */
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification Failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Widget _buildCustomOtpIllustration() {
    return Image.asset(
      'assets/logo/pin.png',
      height: 180,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                horizontal: AppSpacing.screenPadding),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: _goBack,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 20),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        _buildCustomOtpIllustration(),
                        const SizedBox(height: 32),
                        const Text(
                          'Verify Your Number',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'We have sent a 6-digit OTP to',
                          style: AppTextStyles.description,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '+91 ${widget.phoneNumber}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _goBack,
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Pinput(
                          length: 6,
                          controller: _otpController,
                          defaultPinTheme: PinTheme(
                            width: 50,
                            height: 56,
                            textStyle:
                                AppTextStyles.header.copyWith(fontSize: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.divider),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 50,
                            height: 56,
                            textStyle:
                                AppTextStyles.header.copyWith(fontSize: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppColors.primary, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        _timerSeconds > 0
                            ? Text(
                                'Resend OTP in 00:${_timerSeconds.toString().padLeft(2, '0')}',
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              )
                            : GestureDetector(
                                onTap: _goBack,
                                child: const Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isVerifying ? null : _handleVerifyOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: _isVerifying
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Text('Verify & Continue',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ]
                          .animate(interval: 50.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(
                              begin: 0.1,
                              end: 0,
                              duration: 400.ms,
                              curve: Curves.easeOut),
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
}
