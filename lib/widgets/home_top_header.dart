import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../theme/app_theme.dart';
import '../services/api_url.dart';

class HomeTopHeader extends StatelessWidget {
  final String userName;
  final String? profilePhoto;
  final String location;
  final String deliveryTime;
  final int cartCount;
  final VoidCallback onLocationTap;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;

  const HomeTopHeader({
    super.key,
    required this.userName,
    this.profilePhoto,
    required this.location,
    required this.deliveryTime,
    required this.cartCount,
    required this.onLocationTap,
    required this.onCartTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    // Extract first name for the greeting
    final firstName = userName.split(' ').first;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Greetings and Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Good Morning," text
                const Text(
                  'Good Morning,',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                // Name & Emoji
                Text(
                  '$firstName 👋',
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                // "What are you looking for today?"
                const Text(
                  'What are you looking for today?',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                // Location Subtitle
                GestureDetector(
                  onTap: onLocationTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Iconsax.location_copy,
                        size: 16,
                        color: AppColors.primaryAccent,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right Side: Profile & Cart
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Icon
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF2F4F7), // Light greyish background
                    image: profilePhoto != null
                        ? DecorationImage(
                            image: NetworkImage(ApiUrl.imageUrl(profilePhoto!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: profilePhoto == null
                      ? const Center(
                          child: Icon(
                            Icons.person,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Cart Icon with badge
              GestureDetector(
                onTap: onCartTap,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF2F4F7), // Light greyish background
                      ),
                      child: const Center(
                        child: Icon(
                          Iconsax.bag_2,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (cartCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryAccent,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              cartCount > 9 ? '9+' : '$cartCount',
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
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
