import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/lab_test_provider.dart';
import '../../widgets/top_health_tests_list.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/health_packages_horizontal_list.dart';
import 'dart:async';

class LabTestActiveSearchScreen extends ConsumerStatefulWidget {
  const LabTestActiveSearchScreen({super.key});

  @override
  ConsumerState<LabTestActiveSearchScreen> createState() =>
      _LabTestActiveSearchScreenState();
}

class _LabTestActiveSearchScreenState extends ConsumerState<LabTestActiveSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labTestState = ref.watch(labTestProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ref.read(labTestProvider.notifier).searchTests("");
        context.pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Search Lab Tests',
          subtitle: 'Find tests and health packages',
          showBackButton: true,
          onBackTap: () {
            ref.read(labTestProvider.notifier).searchTests("");
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
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
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search for lab tests...',
                  hintStyle: AppTextStyles.cardSubtitle,
                  prefixIcon: const Icon(
                    Iconsax.search_normal_1,
                    color: AppColors.primary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            ref.read(labTestProvider.notifier).searchTests("");
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
                  if (_debounce?.isActive ?? false) _debounce!.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      ref.read(labTestProvider.notifier).searchTests(value);
                      setState(() {});
                    }
                  });
                },
              ),
            ),
          ),

          // Results
          Expanded(
            child: labTestState.isLoadingSearch
                ? const Center(child: CircularProgressIndicator())
                : _searchController.text.isEmpty && labTestState.searchResults.isEmpty
                ? _buildEmptyState('Start typing to search')
                : labTestState.searchResults.isEmpty
                ? _buildEmptyState('No lab tests found')
                : SingleChildScrollView(
                    child: TopHealthTestsList(
                      tests: labTestState.searchResults,
                      selectedTestIds: labTestState.selectedTestIds,
                      onAddTap: (testId) {
                        ref.read(labTestProvider.notifier).toggleTestSelection(testId);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: labTestState.selectedTestIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                ref.read(labTestProvider.notifier).findLabs();
                context.push('/lab-selection');
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.search, color: Colors.white),
              label: Text(
                'Find Labs (${labTestState.selectedTestIds.length})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    final labTestState = ref.watch(labTestProvider);
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.search_status, size: 64, color: AppColors.divider),
                const SizedBox(height: 16),
                Text(message, style: AppTextStyles.cardSubtitle),
              ],
            ),
          ),
        ),
        if (message == 'Start typing to search') ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Popular Health Packages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          HealthPackagesHorizontalList(
            packages: labTestState.featuredPackages,
            onBookTap: (test) {
              ref.read(labTestProvider.notifier).selectTestAndFindLabs(test);
              context.push('/lab-test-details');
            },
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
