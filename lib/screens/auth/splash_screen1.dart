import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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
        context.go('/patho-lab-list');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Animations
          ...List.generate(15, (index) {
            final random = Random();
            final icon = [
              Iconsax.box,
              Iconsax.firstline,
              Iconsax.hospital,
              Iconsax.activity,
              Iconsax.archive_1,
            ][random.nextInt(5)];

            return Positioned(
              left: random.nextDouble() * MediaQuery.of(context).size.width,
              top: random.nextDouble() * MediaQuery.of(context).size.height,
              child:
                  Icon(
                        icon,
                        color: AppColors.primary.withAlpha(20),
                        size: 30 + random.nextDouble() * 40,
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .moveY(
                        begin: 0,
                        end: -20,
                        duration: (2000 + random.nextInt(3000)).ms,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .moveY(
                        begin: -20,
                        end: 0,
                        duration: (2000 + random.nextInt(3000)).ms,
                        curve: Curves.easeInOut,
                      )
                      .rotate(
                        begin: 0,
                        end: 0.1,
                        duration: (3000 + random.nextInt(2000)).ms,
                      ),
            );
          }),

          // Center Logo and Tagline
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(30),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logo/logo.png',
                        width: 120,
                        height: 120,
                      ),
                    )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.easeInOutBack)
                    .fadeIn(),
                const SizedBox(height: 24),
                Text(
                  'MEDY24',
                  style: AppTextStyles.header.copyWith(
                    letterSpacing: 4,
                    color: AppColors.primary,
                  ),
                ).animate().fadeIn(delay: 400.ms).moveY(begin: 20, end: 0),
                const SizedBox(height: 8),
                const Text(
                  'Your Health, Our Priority',
                  style: AppTextStyles.tagline,
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),

          // Bottom Progress Indicator (Optional but adds sleek feel)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 40,
                height: 2,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ).animate().fadeIn(delay: 1000.ms),
          ),
        ],
      ),
    );
  }
}
