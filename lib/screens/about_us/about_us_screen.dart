import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../providers/about_us_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

class AboutUsScreen extends ConsumerWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aboutUsState = ref.watch(aboutUsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'About Us',
        subtitle: 'COMPANY INFORMATION',
        showBackButton: true,
      ),
      body: _buildBody(context, ref, aboutUsState),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, dynamic aboutUsState) {
    if (aboutUsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      );
    }

    if (aboutUsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.danger, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Oops! Something went wrong', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text(aboutUsState.error!, style: AppTextStyles.caption),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(aboutUsProvider.notifier).fetchAboutUs(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (aboutUsState.aboutUsList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document_filter,
              size: 64,
              color: AppColors.textTertiary.withAlpha(100),
            ),
            const SizedBox(height: 16),
            Text('No Information Found', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any company details.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(aboutUsProvider.notifier).fetchAboutUs(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.screenPadding,
        ),
        itemCount: aboutUsState.aboutUsList.length,
        itemBuilder: (context, index) {
          final data = aboutUsState.aboutUsList[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.content,
                  style: AppTextStyles.description,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
