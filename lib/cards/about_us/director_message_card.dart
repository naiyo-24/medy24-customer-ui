import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/about_us.dart';
import '../../theme/app_theme.dart';
import '../../services/api_url.dart';

class DirectorMessageCard extends StatelessWidget {
  final AboutUsModel aboutUs;

  const DirectorMessageCard({super.key, required this.aboutUs});

  @override
  Widget build(BuildContext context) {
    if (aboutUs.directorMessage == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: AppCardStyles.sleekCard,
      child: Stack(
        children: [
          Positioned(
            right: 20,
            top: 20,
            child: Icon(
              Iconsax.quote_up_copy,
              color: AppColors.primary.withAlpha(20),
              size: 60,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding * 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Iconsax.user_tag,
                        color: AppColors.primaryAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Director\'s Message',
                      style: AppTextStyles.cardTitle.copyWith(
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (aboutUs.directorPhoto != null) ...[
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withAlpha(100),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            ApiUrl.imageUrl(aboutUs.directorPhoto!),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 60,
                                  height: 60,
                                  color: AppColors.primary.withAlpha(50),
                                  child: const Icon(
                                    Iconsax.user,
                                    size: 30,
                                    color: AppColors.primary,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (aboutUs.directorName != null)
                            Text(
                              aboutUs.directorName!,
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 16,
                                color: AppColors.primaryAccent,
                              ),
                            ),
                          Text(
                            'Chief Executive Officer',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  aboutUs.directorMessage!,
                  style: AppTextStyles.description.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary.withAlpha(200),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
