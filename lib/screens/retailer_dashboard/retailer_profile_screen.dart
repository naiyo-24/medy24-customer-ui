import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../providers/auth_provider.dart';

class RetailerProfileScreen extends ConsumerWidget {
  const RetailerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        showBackButton: false,
        title: 'Profile & Compliance',
        subtitle: 'Manage your pharmacy settings',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: AppCardStyles.sleekCard,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withAlpha(25),
                    child: const Icon(Iconsax.shop, size: 28, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'My Pharmacy',
                          style: AppTextStyles.cardTitle,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.verified, size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              'Verified Seller',
                              style: AppTextStyles.caption.copyWith(color: Colors.green, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // Options List
            Container(
              decoration: AppCardStyles.sleekCard,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    _buildOption(
                      icon: Iconsax.document_upload,
                      title: 'Document Uploads',
                      subtitle: 'Manage Drug Licenses & PAN',
                      onTap: () {},
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.divider),
                    _buildOption(
                      icon: Iconsax.location,
                      title: 'Pharmacy Location',
                      subtitle: 'Update your address & coordinates',
                      onTap: () {},
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.divider),
                    _buildOption(
                      icon: Iconsax.bank,
                      title: 'Bank Details',
                      subtitle: 'Update payout account information',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // Settings List
            Container(
              decoration: AppCardStyles.sleekCard,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    _buildOption(
                      icon: Iconsax.setting_2,
                      title: 'Settings',
                      onTap: () {},
                    ),
                    const Divider(height: 1, thickness: 1, color: AppColors.divider),
                    _buildOption(
                      icon: Iconsax.logout,
                      title: 'Log Out',
                      titleColor: Colors.red,
                      iconColor: Colors.red,
                      onTap: () {
                        ref.read(authProvider.notifier).logout();
                        context.go('/role-selection');
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: titleColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.caption)
          : null,
      trailing: const Icon(Iconsax.arrow_right_3, size: 16, color: AppColors.textTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding, vertical: 8),
    );
  }
}
