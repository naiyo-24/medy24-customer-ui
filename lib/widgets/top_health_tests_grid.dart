import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/global_lab_test.dart';
import '../providers/lab_test_provider.dart';

class TopHealthTestsGrid extends StatelessWidget {
  final List<GlobalLabTest> tests;
  final Set<String> selectedTestIds;
  final Function(String) onAddTap;

  const TopHealthTestsGrid({
    super.key,
    required this.tests,
    required this.selectedTestIds,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: tests.length,
        itemBuilder: (context, index) {
          final test = tests[index];
          final isSelected = selectedTestIds.contains(test.testId);

          return Consumer(
            builder: (context, ref, child) {
              return GestureDetector(
                onTap: () {
                  ref.read(labTestProvider.notifier).selectTestAndFindLabs(test);
                  context.push('/lab-test-details');
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withAlpha(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: test.isProfile ? Colors.blue.withAlpha(26) : Colors.deepOrange.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          test.isProfile ? Icons.medical_services : Icons.science,
                          color: test.isProfile ? Colors.blue : Colors.deepOrange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Text(
                          test.testName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Prices vary',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => onAddTap(test.testId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? AppColors.success : AppColors.primary.withAlpha(26),
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isSelected ? 'Added' : 'Add',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
