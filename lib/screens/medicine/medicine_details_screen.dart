import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../cards/medicine/medicine_header_card.dart';
import '../../cards/medicine/medicine_description_card.dart';
import '../../cards/medicine/medicine_composition_card.dart';
import '../../cards/medicine/medicine_precautions_card.dart';
import '../../theme/app_theme.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../services/cart_animation_service.dart';

class MedicineDetailsScreen extends ConsumerStatefulWidget {
  const MedicineDetailsScreen({super.key});

  @override
  ConsumerState<MedicineDetailsScreen> createState() => _MedicineDetailsScreenState();
}

class _MedicineDetailsScreenState extends ConsumerState<MedicineDetailsScreen> {
  final GlobalKey _imageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final medicine = ref.watch(medicineProvider).selectedMedicine;

    if (medicine == null) {
      return const Scaffold(body: Center(child: Text('No medicine selected')));
    }

    final cartState = ref.watch(cartProvider);
    final cartItemIndex = cartState.items.indexWhere((item) => item.medicine.medicineId == medicine.medicineId);
    final isInCart = cartItemIndex != -1;
    final cartItem = isInCart ? cartState.items[cartItemIndex] : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            MedicineHeaderCard(medicine: medicine, imageKey: _imageKey),
            const SizedBox(height: AppSpacing.sectionGap),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                children: [
                  MedicineDescriptionCard(medicine: medicine),
                  const SizedBox(height: AppSpacing.elementGap),
                  MedicineCompositionCard(medicine: medicine),
                  const SizedBox(height: AppSpacing.elementGap),
                  MedicinePrecautionsCard(medicine: medicine),
                  const SizedBox(height: 120), // Bottom padding for button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.borderRadius),
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Final Price', style: AppTextStyles.caption),
                  Text(
                    '₹${medicine.finalPrice?.toStringAsFixed(0) ?? '0'}',
                    style: AppTextStyles.subHeader.copyWith(
                      color: AppColors.primary,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.sectionGap),
              Expanded(
                child: isInCart
                  ? Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(24), // matching pill shape of ElevatedButton usually
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => ref.read(cartProvider.notifier).updateQuantity(medicine.medicineId!, cartItem!.quantity - 1),
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Icon(Iconsax.minus, color: Colors.white, size: 20),
                            ),
                          ),
                          Text(
                            '${cartItem!.quantity} in Cart',
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          InkWell(
                            onTap: () => ref.read(cartProvider.notifier).updateQuantity(medicine.medicineId!, cartItem.quantity + 1),
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Icon(Iconsax.add, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        CartAnimationService.triggerAnimation(_imageKey);
                        ref.read(cartProvider.notifier).addItem(medicine);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Added to cart'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Iconsax.shopping_cart, size: 20),
                          SizedBox(width: 10),
                          Text('Add to Cart'),
                        ],
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
