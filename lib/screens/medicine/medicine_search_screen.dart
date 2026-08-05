import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/medicine_provider.dart';
import '../../cards/medicine/medicine_search_card.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import 'dart:async';

class MedicineSearchScreen extends ConsumerStatefulWidget {
  const MedicineSearchScreen({super.key});

  @override
  ConsumerState<MedicineSearchScreen> createState() =>
      _MedicineSearchScreenState();
}

class _MedicineSearchScreenState extends ConsumerState<MedicineSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(medicineProvider.notifier).searchMedicines(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final medicineState = ref.watch(medicineProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Search Medicines',
        subtitle: 'Find medicines and healthcare products',
        showBackButton: true,
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
                  hintText: 'Search for medicines...',
                  hintStyle: AppTextStyles.cardSubtitle,
                  prefixIcon: const Icon(
                    Iconsax.search_normal_1,
                    color: AppColors.primary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            ref.read(medicineProvider.notifier).clearSearch();
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
                      ref.read(medicineProvider.notifier).searchMedicines(searchTerm: value);
                      setState(() {});
                    }
                  });
                },
              ),
            ),
          ),

          // Results
          Expanded(
            child: medicineState.isLoading && medicineState.searchResults.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _searchController.text.isEmpty && medicineState.searchResults.isEmpty
                ? _buildEmptyState('Start typing to search')
                : medicineState.searchResults.isEmpty
                ? _buildEmptyState('No medicines found')
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: medicineState.searchResults.length + (medicineState.isFetchingMoreSearch ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == medicineState.searchResults.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final medicine = medicineState.searchResults[index];
                      return MedicineSearchCard(
                        medicine: medicine,
                        onTap: () {
                          ref
                              .read(medicineProvider.notifier)
                              .selectMedicine(medicine);
                          context.push('/medicine-details');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.search_status, size: 64, color: AppColors.divider),
          const SizedBox(height: 16),
          Text(message, style: AppTextStyles.cardSubtitle),
        ],
      ),
    );
  }
}
