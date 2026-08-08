import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/global_lab_test.dart';
import '../providers/lab_test_provider.dart';
class TopHealthTestsList extends StatelessWidget {
  final List<GlobalLabTest> tests;
  final Set<String> selectedTestIds;
  final Function(String) onAddTap;

  const TopHealthTestsList({
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        final isSelected = selectedTestIds.contains(test.testId);

        return Consumer(
          builder: (context, ref, child) {
            return InkWell(
              onTap: () {
                ref.read(labTestProvider.notifier).selectTestAndFindLabs(test);
                context.push('/lab-test-details');
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.withAlpha(20)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        test.isProfile ? Icons.medical_services : Icons.science,
                        color: test.isProfile ? Colors.blue : Colors.deepOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test.testName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            test.description.isNotEmpty ? test.description : test.category,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Prices vary',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 28,
                          child: ElevatedButton(
                            onPressed: () => onAddTap(test.testId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? AppColors.success : AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(isSelected ? 'Added' : 'Add', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Icon(isSelected ? Icons.check_circle : Icons.add_circle, size: 14),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
