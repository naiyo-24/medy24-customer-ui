import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/lab_test_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

class LabTestDetailsScreen extends ConsumerWidget {
  const LabTestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(labTestProvider);
    final test = state.selectedTestDetails;

    if (test == null) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'Test Details', showBackButton: true),
        body: Center(child: Text('Test not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Test Details',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Details Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppCardStyles.sleekCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: test.isProfile ? Colors.blue.withValues(alpha: 0.1) : Colors.deepOrange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          test.isProfile ? Icons.medical_services : Icons.science,
                          color: test.isProfile ? Colors.blue : Colors.deepOrange,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test.testName,
                              style: AppTextStyles.cardTitle.copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                test.category,
                                style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Description',
                    style: AppTextStyles.subHeader.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    test.description.isNotEmpty ? test.description : 'No description available.',
                    style: AppTextStyles.description,
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 16),
                  
                  // Meta data grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetaItem(
                          icon: Iconsax.drop,
                          title: 'Sample Type',
                          value: test.sampleType.isNotEmpty ? test.sampleType : 'Blood',
                        ),
                      ),
                      Expanded(
                        child: _buildMetaItem(
                          icon: Iconsax.document_text,
                          title: 'Parameters',
                          value: '${test.numberOfParameters} parameters',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetaItem(
                          icon: Iconsax.clock,
                          title: 'Fasting Required',
                          value: test.fastingRequired ? '${test.fastingHours} hours' : 'No',
                        ),
                      ),
                      Expanded(
                        child: _buildMetaItem(
                          icon: Iconsax.info_circle,
                          title: 'Pre-Test Info',
                          value: test.preTestInfo.isNotEmpty ? test.preTestInfo : 'None',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Labs Section
            Text(
              'Available at Labs',
              style: AppTextStyles.subHeader,
            ),
            const SizedBox(height: 16),
            
            if (state.isLoadingLabsForTest)
              const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ))
            else if (state.labsForSelectedTest.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No labs found offering this test.', style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.labsForSelectedTest.length,
                itemBuilder: (context, index) {
                  final lab = state.labsForSelectedTest[index];
                  // Calculate the total price for this specific test from the lab's packages
                  // Assuming the lab has a package that includes this test.
                  return GestureDetector(
                    onTap: () {
                      context.push('/lab-details', extra: lab);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: AppCardStyles.sleekCard,
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.divider.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.business, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lab.labName, style: AppTextStyles.cardTitle),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: AppColors.starYellow),
                                    const SizedBox(width: 4),
                                    Text('${lab.rating} rating', style: AppTextStyles.caption),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₹${lab.totalPrice.toStringAsFixed(0)}',
                                  style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.push('/lab-checkout', extra: lab);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            child: const Text('Book Lab'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem({required IconData icon, required String title, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
