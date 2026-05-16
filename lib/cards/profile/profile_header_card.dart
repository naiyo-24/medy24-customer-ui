import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user.dart';

import '../../services/api_url.dart';

class ProfileHeaderCard extends StatelessWidget {
  final UserModel user;

  const ProfileHeaderCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withAlpha(220),
            AppColors.primaryAccent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(80),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(100),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: user.profilePhoto != null
                      ? Image.network(
                          ApiUrl.imageUrl(user.profilePhoto),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 55,
                              color: AppColors.primary.withAlpha(200),
                            ),
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: AppColors.primary.withAlpha(100),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 55,
                            color: AppColors.primary.withAlpha(200),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? 'Guest User',
                      style: AppTextStyles.header.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '+91 ${user.phoneNumber ?? '00000 00000'}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withAlpha(200),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (user.status == 'active')
                            ? Colors.white.withAlpha(50)
                            : Colors.red.withAlpha(100),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withAlpha(80),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        (user.status ?? 'ACTIVE').toUpperCase(),
                        style: AppTextStyles.tagline.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
