import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/global_lab_test.dart';
import '../providers/lab_test_provider.dart';

class TopHealthTestsHorizontalList extends StatelessWidget {
  final List<GlobalLabTest> tests;
  final Set<String> selectedTestIds;
  final Function(String) onAddTap;

  const TopHealthTestsHorizontalList({
    super.key,
    required this.tests,
    required this.selectedTestIds,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tests.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'No tests available right now.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  width: 150,
                  margin: const EdgeInsets.only(right: 12.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withAlpha(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon and Add Button Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              size: 20,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => onAddTap(test.testId),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.success : AppColors.primary.withAlpha(26),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSelected ? Icons.check : Icons.add,
                                color: isSelected ? Colors.white : AppColors.primary,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Test Name
                      Text(
                        test.testName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Category / Description
                      Text(
                        test.description.isNotEmpty ? test.description : test.category,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Price Info
                      const Text(
                        'Prices vary',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textTertiary,
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
