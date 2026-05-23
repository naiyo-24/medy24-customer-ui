import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../providers/lab_test_provider.dart';
import '../../providers/patho_lab_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../cards/lab_test/lab_test_card.dart';
import '../../widgets/explore_package_card.dart';

class LabTestListScreen extends ConsumerStatefulWidget {
  const LabTestListScreen({super.key});

  @override
  ConsumerState<LabTestListScreen> createState() => _LabTestListScreenState();
}

class _LabTestListScreenState extends ConsumerState<LabTestListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(labTestProvider.notifier).fetchAllTests();
      ref.read(pathoLabProvider.notifier).fetchLabs(status: 'active');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labTestState = ref.watch(labTestProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _isSearching ? null : 'Lab Tests',
        subtitle: _isSearching ? null : 'Book diagnostic tests from best labs',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Iconsax.close_circle : Iconsax.search_normal_1,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchController.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: 8,
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search for tests...',
                  prefixIcon: const Icon(
                    Iconsax.search_normal,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (val) {
                  // Logic for local or API filtering can be added here
                },
              ),
            ),
          Expanded(
            child: labTestState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : labTestState.error != null
                ? Center(child: Text('Error: ${labTestState.error}'))
                : RefreshIndicator(
                    onRefresh: () =>
                        ref.read(labTestProvider.notifier).fetchAllTests(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      itemCount:
                          labTestState.tests.length + (_isSearching ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (!_isSearching && index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: ExplorePackageCard(
                              onTap: () => context.push('/test-package-list'),
                            ),
                          );
                        }

                        final testIndex = _isSearching ? index : index - 1;
                        final test = labTestState.tests[testIndex];
                        return LabTestCard(
                          test: test,
                          onTap: () {
                            context.push('/lab-test-details/${test.testId}');
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
