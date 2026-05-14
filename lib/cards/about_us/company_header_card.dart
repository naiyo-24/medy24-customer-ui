import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/about_us.dart';
import '../../theme/app_theme.dart';
import '../../services/api_url.dart';

class CompanyHeaderCard extends StatelessWidget {
  final AboutUsModel aboutUs;

  const CompanyHeaderCard({super.key, required this.aboutUs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppCardStyles.sleekCard,
      child: Stack(
        children: [
          // Background Gradient Pattern
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withAlpha(40),
                    AppColors.primaryAccent.withAlpha(10),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding * 1.5),
            child: Column(
              children: [
                if (aboutUs.companyPhoto != null)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withAlpha(100),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(50),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.network(
                        ApiUrl.imageUrl(aboutUs.companyPhoto!),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 100,
                          color: AppColors.primary.withAlpha(50),
                          child: const Icon(
                            Iconsax.buildings,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  aboutUs.companyName,
                  style: AppTextStyles.header.copyWith(
                    fontSize: 26,
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (aboutUs.companyTagline != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      aboutUs.companyTagline!.toUpperCase(),
                      style: AppTextStyles.tagline.copyWith(
                        fontSize: 12,
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
