import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../cards/settings/settings_card.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: const CustomAppBar(
        title: 'Settings',
        subtitle: 'APP PREFERENCES',
        showBackButton: true,
      ),
      body: settingsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('General'),
                  SettingsCard(
                    title: 'About Us',
                    icon: Iconsax.info_circle,
                    onTap: () => context.push('/about-us'),
                  ),
                  SettingsCard(
                    title: 'Terms and Conditions',
                    icon: Iconsax.document_text,
                    onTap: () => context.push('/terms-conditions'),
                  ),
                  SettingsCard(
                    title: 'Privacy and Policies',
                    icon: Iconsax.shield_tick,
                    onTap: () => context.push('/privacy-policy'),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Support'),
                  SettingsCard(
                    title: 'Report a Problem',
                    icon: Iconsax.danger,
                    onTap: () => context.push('/report-problem'),
                  ),
                  SettingsCard(
                    title: 'Help Center',
                    icon: Iconsax.support,
                    onTap: () => _showHelpCenterBottomSheet(context),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Account Action'),
                  SettingsCard(
                    title: 'Log Out',
                    icon: Iconsax.logout,
                    iconColor: AppColors.error,
                    showTrailing: false,
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                  SettingsCard(
                    title: 'Delete Account',
                    icon: Iconsax.user_remove,
                    iconColor: AppColors.error,
                    showTrailing: false,
                    onTap: () => _showDeleteDialog(context, ref),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account', style: AppTextStyles.cardTitle),
        content: Text(
          'Are you sure you want to delete your account? This action is permanent and cannot be undone.',
          style: AppTextStyles.description,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(authProvider.notifier).deleteAccount();
              if (success && context.mounted) {
                context.go('/login');
              } else if (context.mounted) {
                final error = ref.read(authProvider).error;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error ?? 'Failed to delete account')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Help Center',
              style: AppTextStyles.subHeader.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Get in touch with us for any queries or support.',
              style: AppTextStyles.description,
            ),
            const SizedBox(height: 24),
            _buildContactItem(
              icon: Iconsax.call,
              title: 'Call us',
              subtitle: '6289171798',
              onTap: () => _launchUrl('tel:6289171798'),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Iconsax.sms,
              title: 'Email',
              subtitle: 'services.naiyo@gmail.com',
              onTap: () => _launchUrl('mailto:services.naiyo@gmail.com'),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Iconsax.location,
              title: 'Location',
              subtitle: 'View on maps (1/30B, Chittaranjan Colony, Baghajatin Colony, Kolkata, West Bengal 700032)',
              onTap: () => _launchUrl('https://maps.google.com/?q=1/30B,+Chittaranjan+Colony,+Baghajatin+Colony,+Kolkata,+West+Bengal+700032'),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Iconsax.global,
              title: 'Website',
              subtitle: 'naiyo24.com',
              onTap: () => _launchUrl('https://naiyo24.com'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

Future<void> _launchUrl(String urlString) async {
  final Uri url = Uri.parse(urlString);
  try {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch \$urlString');
    }
  } catch (e) {
    debugPrint('Error launching url: \$e');
  }
}
