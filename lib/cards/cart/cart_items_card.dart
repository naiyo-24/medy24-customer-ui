import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/cart.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';

class CartItemsCard extends ConsumerWidget {
  const CartItemsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    if (cartState.items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: AppCardStyles.sleekCard,
        child: Center(
          child: Column(
            children: [
              const Icon(Iconsax.shopping_cart, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              Text('Your cart is empty', style: AppTextStyles.cardTitle.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: AppCardStyles.sleekCard,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Iconsax.bag_2, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Text('Items (${cartState.items.length})', style: AppTextStyles.cardTitle),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          ...cartState.items.asMap().entries.map((entry) {
            final isLast = entry.key == cartState.items.length - 1;
            return Column(
              children: [
                _buildCartItem(context, ref, entry.value),
                if (!isLast) const Divider(height: 1, indent: 84),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, WidgetRef ref, CartItem item) {
    final medicine = item.medicine;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/logo/demo_med_image.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.medicineName ?? 'Unknown Medicine',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  medicine.medicineQuantity ?? '',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '₹${medicine.finalPrice?.toStringAsFixed(2) ?? medicine.mrp?.toStringAsFixed(2) ?? ''}',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (medicine.finalPrice != null && medicine.mrp != null && medicine.finalPrice! < medicine.mrp!) ...[
                      const SizedBox(width: 8),
                      Text(
                        '₹${medicine.mrp?.toStringAsFixed(2)}',
                        style: AppTextStyles.caption.copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => ref.read(cartProvider.notifier).updateQuantity(medicine.medicineId!, item.quantity - 1),
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Iconsax.minus, size: 16, color: Colors.white),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(minWidth: 20),
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                InkWell(
                  onTap: () => ref.read(cartProvider.notifier).updateQuantity(medicine.medicineId!, item.quantity + 1),
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Iconsax.add, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
