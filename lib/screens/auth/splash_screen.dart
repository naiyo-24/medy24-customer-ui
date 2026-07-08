import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

import '../../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait for splash animation/branding (minimum 2 seconds)
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    final authState = ref.read(authProvider);

    // If not initialized yet, wait for it
    if (!authState.isInitialized) {
      // We can either poll or use a completer, but simplest is to wait a bit more
      // or rely on ref.listen in build if we want to be reactive.
      // However, loadUser is usually very fast (SharedPreferences).
      int retry = 0;
      while (!ref.read(authProvider).isInitialized && retry < 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        retry++;
      }
    }

    if (mounted) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        context.go('/home');
      } else {
        final prefs = await SharedPreferences.getInstance();

        // TEMPORARY: Reset the memory flag so you can test it again!
        await prefs.remove('has_seen_onboarding');

        final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

        if (!mounted) return;

        if (!hasSeenOnboarding) {
          context.go('/onboarding');
        } else {
          context.go('/login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Colors.white,
              Color(0xFFF1F5F9), // Very soft slate gray for extreme cleanliness
            ],
          ),
        ),
        child: Stack(
          children: [
            // Ambient ripple rings in background
            Center(
              child:
                  Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withAlpha(20),
                            width: 2,
                          ),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        duration: 2500.ms,
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(3.5, 3.5),
                      )
                      .fadeOut(duration: 2500.ms, curve: Curves.easeOut),
            ),
            Center(
              child:
                  Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withAlpha(40),
                            width: 1,
                          ),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        delay: 1250.ms,
                        duration: 2500.ms,
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(3.5, 3.5),
                      )
                      .fadeOut(duration: 2500.ms, curve: Curves.easeOut),
            ),

            // Center Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Premium 3D Logo Reveal
                  Image.asset(
                        'assets/logo/logo.png',
                        width: 240,
                        fit: BoxFit.contain,
                      )
                      .animate()
                      .flip(
                        duration: 1200.ms,
                        curve: Curves.easeOutBack,
                        begin: -0.15,
                        end: 0,
                      )
                      .scale(duration: 1200.ms, curve: Curves.easeOutBack)
                      .fadeIn(duration: 1000.ms)
                      .shimmer(
                        delay: 1200.ms,
                        duration: 2500.ms,
                        color: Colors.white.withAlpha(200),
                      ),

                  const SizedBox(height: 40),

                  // App Name
                  Text(
                        'MEDY24',
                        style: AppTextStyles.header.copyWith(
                          fontSize: 34,
                          letterSpacing: 8,
                          color: AppColors
                              .textPrimary, // Darker color for cleaner contrast
                          fontWeight: FontWeight.w900,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 800.ms)
                      .moveY(
                        begin: 30,
                        end: 0,
                        duration: 800.ms,
                        curve: Curves.easeOutCirc,
                      ),

                  const SizedBox(height: 12),

                  // Tagline
                  Text(
                        'Your Health, Our Priority',
                        style: AppTextStyles.tagline.copyWith(
                          fontSize: 13,
                          letterSpacing: 3.0,
                          color: AppColors.textSecondary,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 800.ms)
                      .moveY(
                        begin: 20,
                        end: 0,
                        duration: 800.ms,
                        curve: Curves.easeOutCirc,
                      ),
                ],
              ),
            ),

            // Minimalist Dot Loader
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        delay: (index * 200).ms,
                        duration: 600.ms,
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.5, 1.5),
                        curve: Curves.easeInOutSine,
                      )
                      .then()
                      .scale(
                        duration: 600.ms,
                        begin: const Offset(1.5, 1.5),
                        end: const Offset(0.5, 0.5),
                        curve: Curves.easeInOutSine,
                      );
                }),
              ).animate().fadeIn(delay: 1500.ms),
            ),
          ],
        ),
      ),
    );
  }
}
