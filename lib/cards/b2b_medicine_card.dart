import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../notifiers/b2b_cart_notifier.dart';
import '../models/b2b_medicine.dart';
import '../theme/app_theme.dart';

class B2bMedicineCard extends ConsumerWidget {
  final B2BMedicineModel med;

  const B2bMedicineCard({super.key, required this.med});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: BorderSide(color: AppColors.divider.withAlpha(128)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Iconsax.health, color: AppColors.info),
              ),
              title: Text(
                med.medicineName,
                style: AppTextStyles.cardTitle,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${med.packSize} • ${med.manufacturer ?? "Generic"}',
                  style: AppTextStyles.caption,
                ),
              ),
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppSpacing.cardRadius),
                      bottomRight: Radius.circular(AppSpacing.cardRadius),
                    ),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: med.availableSellers.isEmpty
                      ? const Center(child: Text("No local distributors have stock.", style: AppTextStyles.caption))
                      : Column(
                          children: med.availableSellers.map((seller) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              color: AppColors.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: AppColors.divider),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  ref.read(b2bCartProvider.notifier).addItem(
                                    distributorId: seller.distributorId,
                                    inventoryId: seller.inventoryId,
                                    qtyBoxes: seller.moq,
                                    ptr: seller.ptr,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Adding ${med.medicineName} to cart...', style: const TextStyle(color: Colors.white)),
                                      backgroundColor: AppColors.primary,
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    )
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      const Icon(Iconsax.shop, color: AppColors.textTertiary, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(seller.companyName, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Batch: ${seller.batchNumber ?? "N/A"} • MOQ: ${seller.moq}',
                                              style: AppTextStyles.caption,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('₹${seller.ptr}', style: AppTextStyles.cardTitle.copyWith(color: AppColors.success)),
                                          Text('MRP ₹${seller.mrp}', style: AppTextStyles.caption.copyWith(decoration: TextDecoration.lineThrough)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
