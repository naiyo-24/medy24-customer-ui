import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../models/manufacturer_models.dart';
import '../../../providers/manufacturer_provider.dart';
import '../../../notifiers/manufacturer_cart_notifier.dart';
import 'manufacturer_checkout_screen.dart';
import 'manufacturer_checkout_screen.dart';

class ManufacturerCatalogScreen extends ConsumerStatefulWidget {
  final ManufacturerModel manufacturer;
  
  const ManufacturerCatalogScreen({super.key, required this.manufacturer});

  @override
  ConsumerState<ManufacturerCatalogScreen> createState() => _ManufacturerCatalogScreenState();
}

class _ManufacturerCatalogScreenState extends ConsumerState<ManufacturerCatalogScreen> {
  @override
  Widget build(BuildContext context) {
    final catalogAsyncValue = ref.watch(manufacturerCatalogProvider(widget.manufacturer.id));
    final cartState = ref.watch(manufacturerCartProvider);
    final cartNotifier = ref.read(manufacturerCartProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.manufacturer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show terms/details
            },
          )
        ],
      ),
      body: catalogAsyncValue.when(
        data: (catalog) {
          if (catalog.isEmpty) return const Center(child: Text('No catalog available.'));
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: catalog.length,
            itemBuilder: (context, index) {
              final med = catalog[index];
              final currentQty = cartState.quantities[med.id] ?? 0;
              return _buildCatalogItem(med, currentQty, cartNotifier);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      bottomNavigationBar: cartState.totalItems > 0 
          ? _buildBottomCheckoutBar(cartState, catalogAsyncValue.value ?? []) 
          : null,
    );
  }

  Widget _buildCatalogItem(ManufacturerMedicineModel med, int currentQty, ManufacturerCartNotifier cartNotifier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(med.name, style: AppTextStyles.cardTitle),
            const SizedBox(height: 4),
            Text('Pack Size: ${med.packSize}', style: AppTextStyles.caption),
            Text('Batch: ${med.batchNumber}', style: AppTextStyles.caption),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PTR: ₹${med.ptr.toStringAsFixed(2)}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text('MRP: ₹${med.mrp.toStringAsFixed(2)}', style: AppTextStyles.caption.copyWith(decoration: TextDecoration.lineThrough)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(25),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    'MOQ: ${med.moq} boxes', 
                    style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            currentQty == 0 
              ? SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => cartNotifier.updateQuantity(med, med.moq),
                    child: Text('Add ${med.moq} Boxes (MOQ)'),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                      onPressed: () => cartNotifier.updateQuantity(med, currentQty == med.moq ? 0 : currentQty - 100),
                    ),
                    Text('$currentQty', style: AppTextStyles.header.copyWith(fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                      onPressed: () => cartNotifier.updateQuantity(med, currentQty + 100),
                    ),
                  ],
                )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCheckoutBar(ManufacturerCartState cartState, List<ManufacturerMedicineModel> catalog) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${cartState.totalItems} boxes selected', style: AppTextStyles.caption),
                Text('Total: ₹${cartState.calculateTotalValue(catalog).toStringAsFixed(2)}', style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary)),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManufacturerCheckoutScreen(
                      manufacturer: widget.manufacturer,
                      catalog: catalog,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Review Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
