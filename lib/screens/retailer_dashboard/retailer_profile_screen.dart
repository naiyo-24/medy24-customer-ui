import 'package:flutter/material.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shop_profile_provider.dart';

class RetailerProfileScreen extends ConsumerWidget {
  const RetailerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final shopProfileAsync = ref.watch(shopProfileProvider);

    return Scaffold(
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        showBackButton: false,
        title: 'Profile & Compliance',
        subtitle: 'Manage your pharmacy settings',
      ),
      body: shopProfileAsync.when(
        data: (shopData) {
          final shopName = shopData?['shopName'] ?? user?.fullName ?? 'My Pharmacy';
          final isVerified = shopData?['isVerified'] ?? false;
          
          return SingleChildScrollView(
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
                              shopName,
                              style: AppTextStyles.cardTitle,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  isVerified ? Icons.verified : Icons.pending, 
                                  size: 16, 
                                  color: isVerified ? Colors.green : Colors.orange
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isVerified ? 'Verified Seller' : 'Pending Verification',
                                  style: AppTextStyles.caption.copyWith(
                                    color: isVerified ? Colors.green : Colors.orange, 
                                    fontWeight: FontWeight.w600
                                  ),
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
                          subtitle: 'View Drug Licenses & PAN',
                          onTap: () {
                            context.push('/retailer-profile/documents');
                          },
                        ),
                        const Divider(height: 1, thickness: 1, color: AppColors.divider),
                        _buildOption(
                          icon: Iconsax.location,
                          title: 'Pharmacy Location',
                          subtitle: 'View address & license details',
                          onTap: () {
                            context.push('/retailer-profile/location');
                          },
                        ),
                        const Divider(height: 1, thickness: 1, color: AppColors.divider),
                        _buildOption(
                          icon: Iconsax.bank,
                          title: 'Bank Details',
                          subtitle: 'View payout account information',
                          onTap: () {
                            context.push('/retailer-profile/bank');
                          },
                        ),
                        const Divider(height: 1, thickness: 1, color: AppColors.divider),
                        _buildOption(
                          icon: Iconsax.box,
                          title: 'Wholesale PO History',
                          subtitle: 'View your B2B purchase orders from distributors',
                          onTap: () {
                            context.push('/retailer-b2b-orders');
                          },
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading profile: $err')),
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
