import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../../providers/charges_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../cards/cart/cart_items_card.dart';
import '../../cards/cart/cart_bill_summary_card.dart';
import '../../cards/cart/cart_tip_card.dart';

import '../../cards/cart/cart_address_card.dart';
import '../../cards/cart/cart_order_pop_up.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chargesProvider.notifier).fetchChargeByServiceType('medicine');
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final chargesState = ref.watch(chargesProvider);
    final bool isCartEmpty = cartState.items.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Shopping Cart',
        subtitle: isCartEmpty
            ? 'Your cart is empty'
            : '${cartState.items.length} items',
        showBackButton: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              children: [
                const CartItemsCard(),
                if (!isCartEmpty) ...[
                  const SizedBox(height: AppSpacing.sectionGap),
                  const CartTipCard(),
                  const SizedBox(height: AppSpacing.sectionGap),
                  const CartBillSummaryCard(),
                  // Give enough padding at bottom for smooth scrolling behind the bottom bar
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
          if (cartState.isLoading)
            const LinearProgressIndicator(color: AppColors.primary),
        ],
      ),
      bottomNavigationBar: isCartEmpty
          ? null
          : Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Delivery Address Row
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (ctx) => Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(ctx).viewInsets.bottom,
                            ),
                            child: const SingleChildScrollView(
                              child: CartAddressCard(),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.divider.withAlpha(128),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Iconsax.home_2,
                                color: AppColors.warning,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Delivering to ${cartState.selectedAddress?['address_type']?.toString().toUpperCase() ?? 'ADDRESS'}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    cartState.selectedAddress?['address_1'] ??
                                        'Select a delivery address',
                                    style: AppTextStyles.caption,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              'Change',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Place Order Row
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (cartState.selectedAddress == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select an address first'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          // Handle COD flow
                          final user =
                              ref.read(profileProvider).user ??
                              ref.read(authProvider).user;
                          final summary = cartState.getSummary(
                            chargesState.selectedCharge,
                          );

                          final selectedAddress =
                              cartState.selectedAddress
                                  as Map<String, dynamic>?;
                          final addressString = [
                            selectedAddress?['address_1'],
                            selectedAddress?['street_address'],
                          ].where((e) => e != null).join(', ');

                          final order = await ref
                              .read(orderProvider.notifier)
                              .placeOrderFromCart(
                                platformFee: summary.platformCharges,
                                deliveryFee: summary.deliveryFees,
                                taxes: summary.taxes,
                                deliveryTip: summary.deliveryTip,
                                paymentMode: 'cod',
                                receiverName: user?.fullName ?? 'Myself',
                                receiverPhone: user?.phoneNumber ?? 'N/A',
                                deliveryAddress: {
                                  'address': addressString,
                                  'lat': selectedAddress?['latitude'] ?? 0.0,
                                  'lng': selectedAddress?['longitude'] ?? 0.0,
                                },
                              );

                          if (order != null) {
                            if (!mounted) return;
                            await showDialog<void>(
                              context: this.context,
                              barrierDismissible: false,
                              builder: (ctx) => CartOrderPopUp(
                                title: 'Order Placed Successfully!',
                                description:
                                    'Thank you for your order. Your medicines will be delivered soon.',
                                trackRoute: order.orderId != null
                                    ? '/order-tracking/${order.orderId}'
                                    : '/my-medicine-orders',
                              ),
                            );
                          } else {
                            if (!mounted) return;
                            final error = ref.read(orderProvider).error;
                            ScaffoldMessenger.of(
                              !mounted ? context : context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(error ?? 'Failed to place order'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₹${cartState.getSummary(chargesState.selectedCharge).totalAmountToBePaid.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Text(
                                  'TOTAL',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: const [
                                Text(
                                  'Request Order',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.play_arrow,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
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
