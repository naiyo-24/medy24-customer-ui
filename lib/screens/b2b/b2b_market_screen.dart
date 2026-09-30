import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../notifiers/b2b_search_notifier.dart';
import '../../notifiers/b2b_cart_notifier.dart';
import '../../widgets/empty_state_widget.dart';
import '../../cards/b2b_medicine_card.dart';

class B2bMarketScreen extends ConsumerStatefulWidget {
  const B2bMarketScreen({super.key});

  @override
  ConsumerState<B2bMarketScreen> createState() => _B2bMarketScreenState();
}

class _B2bMarketScreenState extends ConsumerState<B2bMarketScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(b2bSearchProvider);

    ref.listen<B2BCartState>(b2bCartProvider, (previous, next) {
      if (next.requiresCartClearance == true && previous?.requiresCartClearance != true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.cardRadius)),
            title: Text('Start new order?', style: AppTextStyles.cardTitle),
            content: Text(
              'Your cart contains items from a different distributor. Do you want to clear your cart and start a new order with this distributor?',
              style: AppTextStyles.description,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(b2bCartProvider.notifier).clearCart();
                },
                child: const Text('Clear Cart'),
              ),
            ],
          ),
        );
      }

      if (next.error != null && !next.requiresCartClearance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!, style: AppTextStyles.caption.copyWith(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wholesale Market'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Sleek Search Header
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, 0, AppSpacing.screenPadding, 16),
            child: TextField(
              controller: _searchController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search wholesale (e.g. Dolo 650)',
                prefixIcon: const Icon(Iconsax.search_normal_1, color: AppColors.primaryAccent),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                  borderSide: const BorderSide(color: AppColors.divider, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                  borderSide: const BorderSide(color: AppColors.divider, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (value) {
                // In production, add a 500ms EasyDebounce here
                ref.read(b2bSearchProvider.notifier).searchMedicines(value);
              },
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),

          // Search Results
          Expanded(
            child: searchState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : searchState.error != null
                    ? EmptyStateWidget(title: 'Error occurred', icon: Iconsax.warning_2, subtitle: searchState.error)
                    : searchState.searchResults.isEmpty && _searchController.text.isNotEmpty
                        ? const EmptyStateWidget(title: 'No medicines found', icon: Iconsax.box_search, subtitle: 'Try a different generic or brand name.')
                        : searchState.searchResults.isEmpty
                            ? const EmptyStateWidget(title: 'Search Medicines', icon: Iconsax.search_status, subtitle: 'Find local distributors and compare PTR.')
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 8),
                                itemCount: searchState.searchResults.length,
                                itemBuilder: (context, index) {
                                  final med = searchState.searchResults[index];
                                  return B2bMedicineCard(med: med)
                                      .animate()
                                      .fadeIn(delay: Duration(milliseconds: 50 * index))
                                      .slideX(begin: 0.05, end: 0);
                                },
                              ),
          ),
        ],
      ),
    );
  }
}
