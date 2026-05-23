import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/explore_package_card.dart';
import '../../widgets/order_medicines_card.dart';
import '../../widgets/order_with_prescription_card.dart';
import '../../widgets/book_lab_tests_card.dart';
import '../../widgets/footer_card.dart';
import '../../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        showLogo: true,
        title: 'Medy24',
        subtitle: 'Your Health, Our Priority',
        actions: [
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Iconsax.user, color: AppColors.silver),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Search Bar Placeholder
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.search_normal_1,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Search for medicines, labs, tests...',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Book Lab Tests Card
            BookLabTestsCard(onTap: () => context.push('/lab-test-list')),

            const SizedBox(height: 16),

            // Explore Package Card
            ExplorePackageCard(onTap: () => context.push('/test-package-list')),

            const SizedBox(height: 16),

            // Order Medicines Card
            OrderMedicinesCard(onTap: () => context.push('/medicine-list')),

            const SizedBox(height: 16),

            // Order With Prescription Card
            OrderWithPrescriptionCard(
              onTap: () => context.push('/order-with-prescription'),
            ),

            const SizedBox(height: 32),
            const FooterCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
