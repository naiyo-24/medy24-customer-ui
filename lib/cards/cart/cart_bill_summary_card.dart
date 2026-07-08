import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../providers/cart_provider.dart';
import '../../providers/charges_provider.dart';
import '../../theme/app_theme.dart';

class CartBillSummaryCard extends ConsumerWidget {
  const CartBillSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    if (cartState.items.isEmpty) return const SizedBox.shrink();

    final chargesState = ref.watch(chargesProvider);
    final summary = cartState.getSummary(chargesState.selectedCharge);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.receipt_2, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Bill Summary', style: AppTextStyles.cardTitle),
            ],
          ),
          const SizedBox(height: 16),
          _buildRow('Item Total', summary.totalItemAmount, Iconsax.box),
          if (summary.totalDiscount > 0)
            _buildRow('Item Discount', -summary.totalDiscount, Iconsax.discount_shape, color: AppColors.success),
          if (summary.orderValueDiscount > 0)
            _buildRow('Order Value Offer', -summary.orderValueDiscount, Iconsax.tag, color: AppColors.success),
          _buildRow('Platform Fee', summary.platformCharges, Iconsax.monitor),
          _buildRow('Delivery Fee', summary.deliveryFees, Iconsax.truck_fast),
          if (summary.deliveryTip > 0)
            _buildRow('Delivery Tip', summary.deliveryTip, Icons.motorcycle),
          _buildRow('Taxes', summary.taxes, Iconsax.bank),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total to Pay', style: AppTextStyles.cardTitle.copyWith(fontSize: 18)),
              Text(
                '₹${summary.totalAmountToBePaid.toStringAsFixed(2)}',
                style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary, fontSize: 18),
              ),
            ],
          ),
          if (summary.totalSaved > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: AppColors.success, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'You saved ₹${summary.totalSaved.toStringAsFixed(2)} on this order!',
                    style: AppTextStyles.caption.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, double amount, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: color ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
