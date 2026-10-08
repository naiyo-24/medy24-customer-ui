import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/distributor_models.dart';
import '../../theme/app_theme.dart';
import '../../notifiers/b2b_cart_notifier.dart';

class MedicineDetailsScreen extends ConsumerWidget {
  final DistributorCatalogItemModel medicine;
  final String distributorId;

  const MedicineDetailsScreen({
    super.key,
    required this.medicine,
    required this.distributorId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Medicine Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              decoration: AppCardStyles.sleekCard,
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.health, color: AppColors.info, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.medicineName,
                          style: AppTextStyles.subHeader,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          medicine.manufacturer ?? "Generic Manufacturer",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pricing & Stock
            Container(
              decoration: AppCardStyles.sleekCard,
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PTR (Your Price)', style: AppTextStyles.caption),
                          Text(
                            '₹${medicine.ptr}',
                            style: AppTextStyles.cardTitle.copyWith(color: AppColors.success, fontSize: 18),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('MRP', style: AppTextStyles.caption),
                          Text(
                            '₹${medicine.mrp}',
                            style: AppTextStyles.bodyMedium.copyWith(decoration: TextDecoration.lineThrough),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.divider),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Available Stock:', style: AppTextStyles.bodyMedium),
                      Text(
                        '${medicine.availableStockBoxes} boxes',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Minimum Order Qty:', style: AppTextStyles.bodyMedium),
                      Text(
                        '${medicine.moq} boxes',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Details Section
            Text('Details', style: AppTextStyles.subHeader),
            const SizedBox(height: 12),
            Container(
              decoration: AppCardStyles.sleekCard,
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Pack Size', medicine.packSize),
                  _buildDetailRow('Batch Number', medicine.batchNumber ?? 'N/A'),
                  
                  // NOTE: The backend needs to supply description and composition fields in the catalog response.
                  // For now, they might be missing in DistributorCatalogItemModel, so we show placeholders.
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.divider),
                  ),
                  Text('Description', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'Additional details like description, composition, and precautions will be displayed here once added to the backend.',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // padding for bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                ),
              ),
              icon: const Icon(Iconsax.shopping_cart),
              label: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              onPressed: () async {
                await ref.read(b2bCartProvider.notifier).addItem(
                  distributorId: distributorId,
                  inventoryId: medicine.inventoryId,
                  qtyBoxes: medicine.moq,
                  ptr: medicine.ptr,
                );
                
                final cartError = ref.read(b2bCartProvider).error;
                final requiresClear = ref.read(b2bCartProvider).requiresCartClearance;
                
                if (cartError == null && !requiresClear) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${medicine.medicineName} to cart', style: const TextStyle(color: Colors.white)),
                        backgroundColor: AppColors.primary,
                        duration: const Duration(seconds: 1),
                      )
                    );
                  }
                } else if (requiresClear) {
                  if (context.mounted) {
                    _showClearCartDialog(context, ref);
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
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
