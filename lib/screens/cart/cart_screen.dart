import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../../providers/charges_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import 'package:go_router/go_router.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../cards/cart/cart_items_card.dart';
import '../../cards/cart/cart_bill_summary_card.dart';
import '../../cards/cart/cart_address_card.dart';
import '../../cards/cart/cart_order_pop_up.dart';

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
      ref.read(chargesProvider.notifier).fetchChargeByServiceType('parcel');
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
                  const CartBillSummaryCard(),
                  const SizedBox(height: AppSpacing.sectionGap),
                  const CartAddressCard(),
                  const SizedBox(
                    height: 200,
                  ), // extra padding for bottom navigation
                ],
              ],
            ),
          ),
          if (cartState.isLoading)
            const LinearProgressIndicator(color: AppColors.primary),
        ],
      ),
      bottomSheet: isCartEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: AppTextStyles.cardSubtitle,
                        ),
                        Text(
                          '₹${cartState.getSummary(chargesState.selectedCharge).totalAmountToBePaid.toStringAsFixed(2)}',
                          style: AppTextStyles.cardTitle.copyWith(
                            color: AppColors.primary,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (cartState.selectedAddress == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select an address first',
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

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
                                  builder: (ctx) => const CartOrderPopUp(
                                    title: 'Order Placed Successfully!',
                                    description: 'Thank you for your order. Your medicines will be delivered soon.',
                                    trackRoute: '/my-medicine-orders',
                                  ),
                                );
                                // Do not navigate to home here, the popup handles navigation
                              } else {
                                if (!mounted) return;
                                final error = ref.read(orderProvider).error;
                                ScaffoldMessenger.of(!mounted ? context : context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      error ?? 'Failed to place order',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Pay COD',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              if (cartState.selectedAddress == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select an address first',
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }
                              context.push('/checkout?type=medicine');
                            },
                            child: const Text(
                              'Pay Online',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
