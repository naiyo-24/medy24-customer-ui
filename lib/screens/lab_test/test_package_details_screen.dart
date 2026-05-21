import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../providers/lab_test_provider.dart';
import '../../theme/app_theme.dart';
import '../../cards/lab_test/package_header_card.dart';
import '../../cards/lab_test/package_description_card.dart';
import '../../cards/lab_test/package_included_tests_card.dart';
import '../../cards/lab_test/package_delivery_report_card.dart';

class TestPackageDetailsScreen extends ConsumerStatefulWidget {
  final String packageId;

  const TestPackageDetailsScreen({super.key, required this.packageId});

  @override
  ConsumerState<TestPackageDetailsScreen> createState() => _TestPackageDetailsScreenState();
}

class _TestPackageDetailsScreenState extends ConsumerState<TestPackageDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(labTestProvider.notifier).fetchPackageById(widget.packageId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final labTestState = ref.watch(labTestProvider);
    final package = labTestState.selectedPackage;

    if (labTestState.isLoading && package == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (package == null) {
      return Scaffold(
        body: Center(child: Text(labTestState.error ?? 'Package not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            PackageHeaderCard(
              package: package,
              onBack: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),
            PackageDescriptionCard(package: package),
            PackageIncludedTestsCard(package: package),
            PackageDeliveryReportCard(package: package),
            const SizedBox(height: 100), // Bottom button padding
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBookingBar(package),
    );
  }

  Widget _buildBottomBookingBar(dynamic package) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Package Price',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    '₹${package.packageFinalPrice.toStringAsFixed(0)}',
                    style: AppTextStyles.header.copyWith(
                      fontSize: 26,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              height: 56,
              width: 160,
              child: ElevatedButton(
                onPressed: () {
                  context.push(
                    '/book-test-package?type=package&itemId=${package.packageId}',
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Book Now'),
                    const SizedBox(width: 8),
                    const Icon(Iconsax.arrow_right_3, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
