import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/medicine.dart';
import '../../theme/app_theme.dart';
import '../../widgets/medicine_image.dart';
import '../../providers/cart_provider.dart';

// --- Shared Helpers ---
Widget _buildCartControls(BuildContext context, WidgetRef ref, MedicineModel medicine, bool isOutOfStock) {
  final cartState = ref.watch(cartProvider);
  final cartItemIndex = cartState.items.indexWhere((item) => item.medicine.medicineId == medicine.medicineId);
  final isInCart = cartItemIndex != -1;
  final cartItem = isInCart ? cartState.items[cartItemIndex] : null;

  if (isInCart) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => ref.read(cartProvider.notifier).updateQuantity(medicine.medicineId!, cartItem!.quantity - 1),
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
            child: const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(Iconsax.minus, size: 16, color: Colors.white),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(minWidth: 20),
            child: Text(
              '${cartItem!.quantity}',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          InkWell(
            onTap: () => ref.read(cartProvider.notifier).updateQuantity(medicine.medicineId!, cartItem.quantity + 1),
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
            child: const Padding(
              padding: EdgeInsets.all(6.0),
              child: Icon(Iconsax.add, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  return GestureDetector(
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
        color: isOutOfStock ? AppColors.divider : AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Iconsax.add, size: 16, color: Colors.white),
    ),
  );
}

Widget _buildStockBadge(bool isOutOfStock) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: isOutOfStock ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      isOutOfStock ? 'OUT OF STOCK' : 'IN STOCK',
      style: TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.bold,
        color: isOutOfStock ? AppColors.error : AppColors.success,
      ),
    ),
  );
}

// ==========================================
// Design 1: Compact List View (Recommended)
// ==========================================
class MedicineDesign1 extends ConsumerWidget {
  final MedicineModel medicine;
  final VoidCallback onTap;

  const MedicineDesign1({super.key, required this.medicine, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOutOfStock = medicine.isActive == false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: AppCardStyles.sleekCard,
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 70,
                height: 70,
                child: MedicineImage(
                  photoUrl: medicine.medicinePhoto,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.medicineName ?? 'Unknown Medicine',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicine.medicineQuantity ?? '',
                    style: AppTextStyles.cardSubtitle.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '₹${medicine.finalPrice?.toStringAsFixed(0) ?? '0'}',
                            style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary, fontSize: 16),
                          ),
                          if (medicine.discountPercent != null && medicine.discountPercent! > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '₹${medicine.mrp?.toStringAsFixed(0) ?? '0'}',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, decoration: TextDecoration.lineThrough),
                            ),
                          ],
                        ],
                      ),
                      _buildCartControls(context, ref, medicine, isOutOfStock),
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
}

// ==========================================
// Design 2: 2-Column Grid View
// ==========================================
class MedicineDesign2 extends ConsumerWidget {
  final MedicineModel medicine;
  final VoidCallback onTap;

  const MedicineDesign2({super.key, required this.medicine, required this.onTap});

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
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius)),
                child: MedicineImage(
                  photoUrl: medicine.medicinePhoto,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.medicineName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${medicine.finalPrice?.toStringAsFixed(0) ?? '0'}',
                    style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStockBadge(isOutOfStock),
                      _buildCartControls(context, ref, medicine, isOutOfStock),
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
}

// ==========================================
// Design 3: Ultra-Dense Row (Minimalist)
// ==========================================
class MedicineDesign3 extends ConsumerWidget {
  final MedicineModel medicine;
  final VoidCallback onTap;

  const MedicineDesign3({super.key, required this.medicine, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOutOfStock = medicine.isActive == false;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider.withValues(alpha: 0.5))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.medicineName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${medicine.medicineQuantity ?? ''} • ₹${medicine.finalPrice?.toStringAsFixed(0) ?? '0'}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _buildCartControls(context, ref, medicine, isOutOfStock),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Design 4: Large Showcase Card
// ==========================================
class MedicineDesign4 extends ConsumerWidget {
  final MedicineModel medicine;
  final VoidCallback onTap;

  const MedicineDesign4({super.key, required this.medicine, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOutOfStock = medicine.isActive == false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: AppCardStyles.sleekCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: MedicineImage(
                  photoUrl: medicine.medicinePhoto,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.medicineName ?? '',
                          style: AppTextStyles.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(medicine.medicineQuantity ?? '', style: AppTextStyles.cardSubtitle),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${medicine.finalPrice?.toStringAsFixed(0) ?? '0'}',
                        style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary, fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      _buildCartControls(context, ref, medicine, isOutOfStock),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Design 5: 3-Column Dense Grid
// ==========================================
class MedicineDesign5 extends ConsumerWidget {
  final MedicineModel medicine;
  final VoidCallback onTap;

  const MedicineDesign5({super.key, required this.medicine, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOutOfStock = medicine.isActive == false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: MedicineImage(
                photoUrl: medicine.medicinePhoto,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              medicine.medicineName ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '₹${medicine.finalPrice?.toStringAsFixed(0) ?? '0'}',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildCartControls(context, ref, medicine, isOutOfStock),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// Design 6: Premium Detailed Card
// ==========================================
class MedicineDesign6 extends ConsumerWidget {
  final MedicineModel medicine;
  final VoidCallback onTap;

  const MedicineDesign6({super.key, required this.medicine, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOutOfStock = medicine.isActive == false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: MedicineImage(
                  photoUrl: medicine.medicinePhoto,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          medicine.medicineName ?? 'Unknown',
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Iconsax.heart, size: 18, color: AppColors.textTertiary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicine.medicineQuantity ?? '',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '₹${medicine.finalPrice?.toStringAsFixed(0) ?? '0'}',
                            style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary, fontSize: 16),
                          ),
                          if (medicine.discountPercent != null && medicine.discountPercent! > 0)
                            Text(
                              '₹${medicine.mrp?.toStringAsFixed(0) ?? '0'}',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                      _buildCartControls(context, ref, medicine, isOutOfStock),
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
}
