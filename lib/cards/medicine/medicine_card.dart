import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/medicine.dart';
import '../../theme/app_theme.dart';
import '../../services/api_url.dart';
import '../../providers/cart_provider.dart';

class MedicineCard extends ConsumerWidget {
  final MedicineModel medicine;
  final VoidCallback onTap;

  const MedicineCard({super.key, required this.medicine, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOutOfStock = medicine.isActive == false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppCardStyles.sleekCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.cardRadius),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.3,
                    child: Image.asset(
                      'assets/logo/demo_med_image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (medicine.discountPercent != null &&
                    medicine.discountPercent! > 0)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${medicine.discountPercent!.toInt()}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.medicineName ?? 'Unknown Medicine',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicine.medicineQuantity ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardSubtitle,
                  ),
                  const SizedBox(height: 8),

                  // Price Section
                  Row(
                    children: [
                      Text(
                        '₹${medicine.finalPrice?.toStringAsFixed(0) ?? '0'}',
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (medicine.discountPercent != null &&
                          medicine.discountPercent! > 0)
                        Text(
                          '₹${medicine.mrp?.toStringAsFixed(0) ?? '0'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Stock and Add to Cart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isOutOfStock
                              ? AppColors.error.withAlpha(30)
                              : AppColors.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isOutOfStock ? 'OUT OF STOCK' : 'IN STOCK',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: isOutOfStock
                                ? AppColors.error
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: isOutOfStock ? null : () {
                          ref.read(cartProvider.notifier).addItem(medicine);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Added to cart'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? AppColors.divider
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.add,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.divider,
      child: Center(child: Icon(Iconsax.box, color: AppColors.textSecondary)),
    );
  }
}
