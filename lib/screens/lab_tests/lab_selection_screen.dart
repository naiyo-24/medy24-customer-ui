import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/lab_test_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../models/lab_package.dart';

class LabSelectionScreen extends ConsumerWidget {
  const LabSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(labTestProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Select Lab',
        subtitle: 'Choose a lab for your tests',
        showBackButton: true,
      ),
      body: state.isLoadingLabs
          ? const Center(child: CircularProgressIndicator())
          : state.matchedLabs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.hospital, size: 64, color: AppColors.divider),
                      const SizedBox(height: 16),
                      Text("No labs found for these tests.", style: AppTextStyles.bodyMedium),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.matchedLabs.length,
                  itemBuilder: (context, index) {
                    final lab = state.matchedLabs[index];
                    return _LabPackageCard(lab: lab);
                  },
                ),
    );
  }
}

class _LabPackageCard extends StatelessWidget {
  final LabPackage lab;

  const _LabPackageCard({required this.lab});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lab.labName,
                        style: AppTextStyles.header.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            lab.rating.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (lab.isFullMatch)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.verify, color: AppColors.success, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Full Match",
                          style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
              ],
            ),
            const Divider(height: 24),
            
            // Matched Tests
            Text("Available Tests (${lab.matchedTests.length})", style: AppTextStyles.subHeader),
            const SizedBox(height: 8),
            ...lab.matchedTests.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(t.testName, style: AppTextStyles.bodyMedium),
                      ),
                      Text("₹${t.price.toStringAsFixed(0)}", style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
            
            // Missing Tests
            if (lab.missingTests.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(13),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withAlpha(51)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cancel, color: AppColors.error, size: 16),
                        const SizedBox(width: 6),
                        Text("Not Available Here (${lab.missingTests.length})",
                            style: AppTextStyles.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...lab.missingTests.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text("• ${t.testName}",
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  decoration: TextDecoration.lineThrough)),
                        )),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Footer & Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Price", style: AppTextStyles.caption),
                    Text(
                      "₹${lab.totalPrice.toStringAsFixed(0)}",
                      style: AppTextStyles.subHeader.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: lab.matchedTests.isEmpty ? null : () {
                    // Navigate to checkout with this specific lab
                    context.push('/lab-checkout', extra: lab);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Select Lab",
                    style: AppTextStyles.cardTitle.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
