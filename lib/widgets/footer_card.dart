import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FooterCard extends StatelessWidget {
  const FooterCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(2), // Near invisible background
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        children: [
          // Medy24 with Greyish Overlay
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppColors.textPrimary.withAlpha(20),
                AppColors.textPrimary.withAlpha(80),
                AppColors.textPrimary.withAlpha(20),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'Medy24',
              style: AppTextStyles.header.copyWith(
                fontSize: 42,
                color: Colors.white,
                letterSpacing: -2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tagline with greyish look
          Text(
            'YOUR HEALTH • OUR PRIORITY',
            style: AppTextStyles.tagline.copyWith(
              fontSize: 10,
              color: AppColors.textTertiary.withAlpha(120),
              letterSpacing: 4,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 48),

          // Location / Made with Love
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider.withAlpha(50)),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Made with ',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary.withAlpha(150),
                    fontSize: 11,
                  ),
                ),
                const Icon(Icons.favorite, size: 12, color: AppColors.error),
                Text(
                  ' in Kolkata, India',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary.withAlpha(200),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Minimal Copyright
          Text(
            '© 2026 MEDY24 HEALTH SERVICES',
            style: AppTextStyles.caption.copyWith(
              fontSize: 9,
              color: AppColors.textTertiary.withAlpha(80),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
