import 'package:flutter/material.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../providers/profile_provider.dart';
import '../../cards/profile/profile_header_card.dart';
import '../../cards/profile/profile_options_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(profileProvider.notifier).fetchProfile());
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final user = profileState.user;

    return Scaffold(
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        showBackButton: true,
        title: 'Profile',
        subtitle: 'Manage your personal info',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            if (profileState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (user != null) ...[
              ProfileHeaderCard(user: user),
              const SizedBox(height: AppSpacing.sectionGap),
            ],
            const ProfileOptionsCard(),
            const SizedBox(height: AppSpacing.sectionGap),
          ],
        ),
      ),
    );
  }
}
