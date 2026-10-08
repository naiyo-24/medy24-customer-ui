import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../notifiers/distributor_catalog_notifier.dart';
import '../../notifiers/b2b_cart_notifier.dart';
import '../../widgets/empty_state_widget.dart';
import '../../models/distributor_models.dart';

class DistributorCatalogScreen extends ConsumerStatefulWidget {
  final String distributorId;
  final String companyName;

  const DistributorCatalogScreen({
    super.key,
    required this.distributorId,
    required this.companyName,
  });

  @override
  ConsumerState<DistributorCatalogScreen> createState() => _DistributorCatalogScreenState();
}

class _DistributorCatalogScreenState extends ConsumerState<DistributorCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(distributorCatalogProvider.notifier).fetchCatalog(widget.distributorId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(distributorCatalogProvider);
    final cartState = ref.watch(b2bCartProvider);

    // Client-side filtering
    final filteredCatalog = _searchQuery.isEmpty 
        ? catalogState.catalog 
        : catalogState.catalog.where((item) => 
            item.medicineName.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

    ref.listen<B2BCartState>(b2bCartProvider, (previous, next) {
      if (next.requiresCartClearance && previous?.requiresCartClearance != true) {
        if (ModalRoute.of(context)?.isCurrent == true) {
          _showClearCartDialog();
        }
      }
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
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.companyName),
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
                hintText: 'Search within catalog...',
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
                setState(() {
                  _searchQuery = value.trim();
                });
              },
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0),

          // Catalog List
          Expanded(
            child: catalogState.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : catalogState.error != null
                    ? EmptyStateWidget(title: 'Error occurred', icon: Iconsax.warning_2, subtitle: catalogState.error)
                    : catalogState.catalog.isEmpty
                        ? const EmptyStateWidget(
                            title: 'Empty Catalog', 
                            icon: Iconsax.box, 
                            subtitle: 'This distributor currently has no inventory in stock.'
                          )
                        : filteredCatalog.isEmpty
                            ? const EmptyStateWidget(
                                title: 'No match found', 
                                icon: Iconsax.box_search, 
                                subtitle: 'Try searching for a different medicine.'
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: 8),
                                itemCount: filteredCatalog.length,
                                itemBuilder: (context, index) {
                                  final item = filteredCatalog[index];
                                  return _buildCatalogItemCard(item)
                                      .animate()
                                      .fadeIn(delay: Duration(milliseconds: 20 * index))
                                      .slideX(begin: 0.05, end: 0);
                                },
                              ),
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

  Widget _buildCatalogItemCard(DistributorCatalogItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppCardStyles.sleekCard,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Iconsax.health, color: AppColors.info, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.medicineName, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 2),
                      Text(
                        '${item.packSize} • ${item.manufacturer ?? "Generic"}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₹${item.ptr}', style: AppTextStyles.cardTitle.copyWith(color: AppColors.success)),
                    Text('MRP ₹${item.mrp}', style: AppTextStyles.caption.copyWith(decoration: TextDecoration.lineThrough)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Batch: ${item.batchNumber ?? "N/A"}',
                  style: AppTextStyles.caption,
                ),
                Row(
                  children: [
                    Text(
                      'MOQ: ${item.moq} boxes',
                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton.icon(
                        icon: const Icon(Iconsax.shopping_cart, size: 16),
                        label: const Text('Add'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          await ref.read(b2bCartProvider.notifier).addItem(
                            distributorId: widget.distributorId,
                            inventoryId: item.inventoryId,
                            qtyBoxes: item.moq,
                            ptr: item.ptr,
                          );
                          
                          // Check if error occurred (e.g. Swiggy Rule)
                          final cartError = ref.read(b2bCartProvider).error;
                          final requiresClear = ref.read(b2bCartProvider).requiresCartClearance;
                          
                          if (cartError == null && !requiresClear) {
                            if (context.mounted) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added ${item.medicineName} to cart', style: const TextStyle(color: Colors.white)),
                                  backgroundColor: AppColors.primary,
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                )
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
