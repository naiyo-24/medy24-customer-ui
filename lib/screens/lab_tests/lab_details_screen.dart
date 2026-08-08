import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/lab_package.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

class LabDetailsScreen extends StatelessWidget {
  final LabPackage lab;

  const LabDetailsScreen({super.key, required this.lab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: lab.labName,
        subtitle: 'Lab Details',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lab Header Info
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          lab.labName,
                          style: AppTextStyles.header.copyWith(fontSize: 22),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              lab.rating.toStringAsFixed(1),
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Placeholder for address
                  Row(
                    children: [
                      const Icon(Iconsax.location, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Sector V, Salt Lake, Kolkata, West Bengal 700091',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Certifications placeholder
                  Row(
                    children: [
                      _buildBadge('NABL Certified', AppColors.success),
                      const SizedBox(width: 8),
                      _buildBadge('ISO 9001:2015', Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // About the Lab Placeholder
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("About this Lab", style: AppTextStyles.subHeader),
                  const SizedBox(height: 8),
                  Text(
                    "This laboratory is equipped with state-of-the-art technology and certified professionals to provide accurate and timely results for all your diagnostic needs.",
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Available Tests
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text("Available Tests (${lab.matchedTests.length})", style: AppTextStyles.subHeader),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...lab.matchedTests.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(t.testName, style: AppTextStyles.bodyMedium),
                            ),
                            Text("₹${t.price.toStringAsFixed(0)}", style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Missing Tests
            if (lab.missingTests.isNotEmpty) ...[
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cancel, color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Text("Not Available Here (${lab.missingTests.length})", style: AppTextStyles.subHeader.copyWith(color: AppColors.error)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...lab.missingTests.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.remove, size: 14, color: AppColors.textTertiary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  t.testName, 
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Price", style: AppTextStyles.caption),
                  Text(
                    "₹${lab.totalPrice.toStringAsFixed(0)}",
                    style: AppTextStyles.header.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: lab.matchedTests.isEmpty ? null : () {
                  context.push('/lab-checkout', extra: lab);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Proceed to Checkout",
                  style: AppTextStyles.cardTitle.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        border: Border.all(color: color.withAlpha(51)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
