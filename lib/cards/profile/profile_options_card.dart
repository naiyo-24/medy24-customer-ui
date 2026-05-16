import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class ProfileOptionsCard extends StatelessWidget {
  const ProfileOptionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            'ACCOUNT SETTINGS',
            style: AppTextStyles.tagline.copyWith(
              color: AppColors.textTertiary,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: AppColors.divider.withAlpha(100)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Column(
              children: [
                _buildOption(
                  icon: Iconsax.user_edit,
                  title: 'Update Profile',
                  subtitle: 'Manage your personal details',
                  color: AppColors.primary,
                  onTap: () => context.push('/update-profile'),
                ),
                _buildDivider(),
                _buildOption(
                  icon: Iconsax.shopping_cart,
                  title: 'My Cart',
                  subtitle: 'View items in your basket',
                  color: AppColors.primary,
                  onTap: () {},
                ),
                _buildDivider(),
                _buildOption(
                  icon: Iconsax.location,
                  title: 'My Addresses',
                  subtitle: 'Manage your addresses',
                  color: AppColors.primary,
                  onTap: () => context.push('/saved-addresses'),
                ),
                _buildDivider(),
                _buildOption(
                  icon: Iconsax.bag_2,
                  title: 'My Orders',
                  subtitle: 'Track your medicine deliveries',
                  color: AppColors.primary,
                  onTap: () {},
                ),
                _buildDivider(),
                _buildOption(
                  icon: Iconsax.calendar_tick,
                  title: 'My Test Bookings',
                  subtitle: 'Check your lab test status',
                  color: AppColors.primary,
                  onTap: () {},
                ),
                _buildDivider(),
                _buildOption(
                  icon: Iconsax.info_circle,
                  title: 'About Us',
                  subtitle: 'Learn more about Medy24',
                  color: AppColors.primary,
                  onTap: () => context.push('/about-us'),
                ),
                _buildDivider(),
                _buildOption(
                  icon: Iconsax.notification,
                  title: 'Notifications',
                  subtitle: 'Health tips and order updates',
                  color: AppColors.primary,
                  isLast: true,
                  onTap: () {},
                ),
                _buildDivider(),
                _buildOption(
                  icon: Iconsax.setting,
                  title: 'Settings',
                  subtitle: 'Manage app settings',
                  color: AppColors.primary,
                  isLast: true,
                  onTap: () => context.push('/settings'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Iconsax.arrow_right_3,
            size: 14,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 80,
      endIndent: 20,
      color: AppColors.divider.withAlpha(50),
    );
  }
}
