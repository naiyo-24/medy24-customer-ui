import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../notifiers/nearby_distributors_notifier.dart';
import '../../notifiers/b2b_search_notifier.dart';
import '../../notifiers/b2b_cart_notifier.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/empty_state_widget.dart';
import '../../models/distributor_models.dart';
import 'distributor_catalog_screen.dart';
import '../../cards/b2b_medicine_card.dart';

class B2bMarketScreen extends ConsumerStatefulWidget {
  const B2bMarketScreen({super.key});

  @override
  ConsumerState<B2bMarketScreen> createState() => _B2bMarketScreenState();
}

class _B2bMarketScreenState extends ConsumerState<B2bMarketScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(nearbyDistributorsProvider.notifier).fetchNearbyDistributors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(b2bSearchProvider);
    final nearbyState = ref.watch(nearbyDistributorsProvider);
    final cartState = ref.watch(b2bCartProvider);

    ref.listen<B2BCartState>(b2bCartProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error && !next.requiresCartClearance) {
        if (ModalRoute.of(context)?.isCurrent == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!, style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
      if (next.requiresCartClearance && previous?.requiresCartClearance != true) {
        if (ModalRoute.of(context)?.isCurrent == true) {
          _showClearCartDialog();
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wholesale Market'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.shopping_cart),
            onPressed: () => context.push('/b2b-checkout'),
          ),
        ],
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
                hintText: 'Search medicines (e.g. Dolo 650)',
                prefixIcon: const Icon(Iconsax.search_normal_1, color: AppColors.primaryAccent),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Iconsax.close_circle, color: AppColors.textTertiary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _isSearching = false);
                          ref.read(b2bSearchProvider.notifier).searchMedicines('');
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
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
                setState(() => _isSearching = value.trim().isNotEmpty);
                ref.read(b2bSearchProvider.notifier).searchMedicines(value);
              },
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),

          // Content Area
          Expanded(
            child: _isSearching
                ? _buildSearchResults(searchState)
                : _buildNearbyDistributors(nearbyState),
          ),
        ],
      ),
      floatingActionButton: cartState.totalEstimatedPrice > 0
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/b2b-checkout'),
              backgroundColor: AppColors.primary,
              icon: const Icon(Iconsax.shopping_cart, color: Colors.white),
              label: Text(
                'Checkout (₹${cartState.totalEstimatedPrice.toStringAsFixed(0)})',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildSearchResults(B2BSearchState searchState) {
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (searchState.error != null) {
      return EmptyStateWidget(title: 'Error occurred', icon: Iconsax.warning_2, subtitle: searchState.error);
    }
    if (searchState.searchResults.isEmpty) {
      return const EmptyStateWidget(title: 'No medicines found', icon: Iconsax.box_search, subtitle: 'Try a different generic or brand name.');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 8),
      itemCount: searchState.searchResults.length,
      itemBuilder: (context, index) {
        final med = searchState.searchResults[index];
        return B2bMedicineCard(med: med)
            .animate()
            .fadeIn(delay: Duration(milliseconds: 50 * index))
            .slideX(begin: 0.05, end: 0);
      },
    );
  }

  Widget _buildNearbyDistributors(NearbyDistributorsState nearbyState) {
    if (nearbyState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (nearbyState.error != null) {
      return EmptyStateWidget(title: 'Error occurred', icon: Iconsax.warning_2, subtitle: nearbyState.error);
    }
    if (nearbyState.distributors.isEmpty) {
      return const EmptyStateWidget(title: 'No distributors found', icon: Iconsax.shop, subtitle: 'There are no active wholesale distributors in your area.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 8),
          child: const Text('Nearby Distributors', style: AppTextStyles.header),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 8),
            itemCount: nearbyState.distributors.length,
            itemBuilder: (context, index) {
              final dist = nearbyState.distributors[index];
              return _buildDistributorCard(dist)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 50 * index))
                  .slideY(begin: 0.1, end: 0);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDistributorCard(NearbyDistributorModel dist) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: BorderSide(color: AppColors.divider.withAlpha(128)),
      ),
      child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DistributorCatalogScreen(
                  distributorId: dist.distributorId,
                  companyName: dist.companyName,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Iconsax.shop, color: AppColors.info, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dist.companyName,
                        style: AppTextStyles.cardTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Iconsax.location, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '${dist.distanceKm.toStringAsFixed(1)} km away',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Iconsax.arrow_right_3, color: AppColors.textTertiary, size: 20),
              ],
            ),
          ),
        ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Your cart contains items from another distributor. Do you want to clear your cart to add this item?'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(b2bCartProvider.notifier).cancelCartClearance();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              ref.read(b2bCartProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear Cart', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
