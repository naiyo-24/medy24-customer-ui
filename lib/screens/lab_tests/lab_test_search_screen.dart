import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/lab_test_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

class LabTestSearchScreen extends ConsumerStatefulWidget {
  const LabTestSearchScreen({super.key});

  @override
  ConsumerState<LabTestSearchScreen> createState() => _LabTestSearchScreenState();
}

class _LabTestSearchScreenState extends ConsumerState<LabTestSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(labTestProvider);
    final notifier = ref.read(labTestProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Book Lab Tests',
        subtitle: 'Search blood tests, MRI, etc.',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search blood tests, MRI, etc.',
                  hintStyle: AppTextStyles.cardSubtitle,
                  prefixIcon: const Icon(
                    Iconsax.search_normal_1,
                    color: AppColors.primary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            notifier.searchTests("");
                            setState(() {});
                          },
                          icon: const Icon(
                            Iconsax.close_circle,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                onChanged: (value) {
                  notifier.searchTests(value);
                  setState(() {});
                },
              ),
            ),
          ),

          // Results
          Expanded(
            child: state.isLoadingSearch
                ? const Center(child: CircularProgressIndicator())
                : state.searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.search_status, size: 64, color: AppColors.divider),
                            const SizedBox(height: 16),
                            Text("No tests found", style: AppTextStyles.cardSubtitle),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                            bottom: 100), // padding for FAB
                        itemCount: state.searchResults.length,
                        itemBuilder: (context, index) {
                          final test = state.searchResults[index];
                          final isSelected = state.selectedTestIds.contains(test.testId);

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withAlpha(26) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                if (!isSelected)
                                  BoxShadow(
                                    color: Colors.black.withAlpha(5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              title: Text(test.testName, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  "${test.category} • ${test.sampleType}",
                                  style: AppTextStyles.cardSubtitle,
                                ),
                              ),
                              trailing: Checkbox(
                                value: isSelected,
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  notifier.toggleTestSelection(test.testId);
                                },
                              ),
                              onTap: () {
                                notifier.toggleTestSelection(test.testId);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: state.selectedTestIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                notifier.findLabs();
                context.push('/lab-selection');
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Iconsax.magic_star, color: Colors.white),
              label: Text("Find Labs (${state.selectedTestIds.length}) ➔", style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
