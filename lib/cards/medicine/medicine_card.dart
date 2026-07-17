import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/medicine.dart';
import '../../theme/app_theme.dart';

import '../../providers/cart_provider.dart';
import '../../services/cart_animation_service.dart';

class MedicineCard extends ConsumerStatefulWidget {
  final MedicineModel medicine;
  final VoidCallback onTap;

  const MedicineCard({super.key, required this.medicine, required this.onTap});

  @override
  ConsumerState<MedicineCard> createState() => _MedicineCardState();
}

class _MedicineCardState extends ConsumerState<MedicineCard> {
  final GlobalKey _imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = widget.medicine.isActive == false;
    final cartState = ref.watch(cartProvider);
    final cartItemIndex = cartState.items.indexWhere((item) => item.medicine.medicineId == widget.medicine.medicineId);
    final isInCart = cartItemIndex != -1;
    final cartItem = isInCart ? cartState.items[cartItemIndex] : null;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: AppCardStyles.sleekCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.cardRadius),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      key: _imageKey,
                      child: Image.asset(
                        'assets/logo/demo_med_image.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (widget.medicine.discountPercent != null &&
                    widget.medicine.discountPercent! > 0)
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
                        '${widget.medicine.discountPercent!.toInt()}% OFF',
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
          ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.medicine.medicineName ?? 'Unknown Medicine',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.medicine.medicineQuantity ?? '',
                    style: AppTextStyles.cardSubtitle,
                  ),
                  const SizedBox(height: 8),

                  // Price Section
                  Row(
                    children: [
                      Text(
                        '₹${widget.medicine.finalPrice?.toStringAsFixed(0) ?? '0'}',
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (widget.medicine.discountPercent != null &&
                          widget.medicine.discountPercent! > 0)
                        Text(
                          '₹${widget.medicine.mrp?.toStringAsFixed(0) ?? '0'}',
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
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
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
                          ),
                        ),
                      ),
                      isInCart
                          ? Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => ref.read(cartProvider.notifier).updateQuantity(widget.medicine.medicineId!, cartItem!.quantity - 1),
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
                                    onTap: () => ref.read(cartProvider.notifier).updateQuantity(widget.medicine.medicineId!, cartItem.quantity + 1),
                                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                    child: const Padding(
                                      padding: EdgeInsets.all(6.0),
                                      child: Icon(Iconsax.add, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: isOutOfStock ? null : () {
                                CartAnimationService.triggerAnimation(_imageKey);
                                ref.read(cartProvider.notifier).addItem(widget.medicine);
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
}
