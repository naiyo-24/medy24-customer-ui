import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/charges_provider.dart';
import '../../services/razorpay_payment_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../cards/cart/cart_order_pop_up.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String checkoutType; // 'medicine'
  const CheckoutScreen({super.key, this.checkoutType = 'medicine'});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final RazorpayPaymentService _razorpayService = RazorpayPaymentService();
  bool _isPaying = false;

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  Future<void> _onProceed() async {
    setState(() => _isPaying = true);
    final user = ref.read(profileProvider).user ?? ref.read(authProvider).user;
    await _requestQuotesForMedicine(user);
  }

  Future<void> _requestQuotesForMedicine(dynamic user) async {
    final cartState = ref.read(cartProvider);
    final chargesState = ref.read(chargesProvider);
    final summary = cartState.getSummary(chargesState.selectedCharge);

    if (cartState.selectedAddress == null) {
      setState(() => _isPaying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No address selected')));
      return;
    }

    final selectedAddress = cartState.selectedAddress as Map<String, dynamic>?;
    final addressString = [
      selectedAddress?['address_1'],
      selectedAddress?['street_address'],
    ].where((e) => e != null).join(', ');

    // Place the order as a quote request
    final order = await ref
        .read(orderProvider.notifier)
        .placeOrderFromCart(
          cartItems: cartState.items,
          itemTotal: summary.totalItemAmount - summary.totalDiscount - summary.orderValueDiscount,
          totalBillAmount: summary.totalAmountToBePaid,
          platformFee: summary.platformCharges,
          deliveryFee: summary.deliveryFees,
          taxes: summary.taxes,
          deliveryTip: summary.deliveryTip,
          paymentMode:
              'cod', // Payment will be chosen later upon quote acceptance
          receiverName: user?.fullName ?? 'Myself',
          receiverPhone: user?.phoneNumber ?? 'N/A',
          deliveryAddress: {
            'address': addressString,
            'lat': selectedAddress?['latitude'] ?? 0.0,
            'lng': selectedAddress?['longitude'] ?? 0.0,
          },
        );

    if (order == null) {
      if (!mounted) return;
      setState(() => _isPaying = false);
      final error = ref.read(orderProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to request quotes')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isPaying = false);
    _showSuccessAndExit();
  }

  Future<void> _showSuccessAndExit() async {
    String msg = '';
    String trackRoute = '';
      msg = 'Your quote request has been sent to nearby pharmacies.';
      trackRoute = '/my-medicine-orders'; // We redirect them to orders list where they can see quotes

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CartOrderPopUp(
        title: 'Payment successful',
        description: msg,
        trackRoute: trackRoute,
      ),
    );
    // Navigation is handled by the popup
  }

  @override
  Widget build(BuildContext context) {
    return _buildMedicineUI();
  }

  Widget _buildMedicineUI() {
    final cartState = ref.watch(cartProvider);
    final chargesState = ref.watch(chargesProvider);
    final summary = cartState.getSummary(chargesState.selectedCharge);

    if (cartState.items.isEmpty) {
      return const Scaffold(
        appBar: CustomAppBar(
          showBackButton: true,
          title: 'Checkout',
          subtitle: 'Review and pay',
        ),
        body: Center(child: Text('Cart is empty')),
      );
    }

    final user = ref.read(profileProvider).user ?? ref.read(authProvider).user;
    final orderState = ref.watch(orderProvider);
    final selectedAddress = cartState.selectedAddress as Map<String, dynamic>?;
    final addressString = [
      selectedAddress?['address_1'],
      selectedAddress?['street_address'],
    ].where((e) => e != null).join(', ');

    return _buildCheckoutLayout(
      title: 'Medicine Order',
      subtitle: '${cartState.items.length} items',
      patientName: user?.fullName ?? 'Myself',
      address: addressString,
      subtotal: summary.totalItemAmount,
      discount: summary.totalDiscount,
      platformFee: summary.platformCharges,
      deliveryFee: summary.deliveryFees,
      taxCharges: summary.taxes,
      totalAmount: summary.totalAmountToBePaid,
      isSubmitting: orderState.isLoading,
      buttonText: 'Request Quotes',
      paymentMethodText: 'Select Later',
      paymentMethodDesc: 'Choose payment method after accepting a quote',
    );
  }

  Widget _buildCheckoutLayout({
    required String title,
    String? subtitle,
    required String patientName,
    required String address,
    required double subtotal,
    required double discount,
    required double platformFee,
    required double deliveryFee,
    required double taxCharges,
    required double totalAmount,
    required bool isSubmitting,
    required String buttonText,
    required String paymentMethodText,
    required String paymentMethodDesc,
  }) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        showBackButton: true,
        title: 'Checkout',
        subtitle: 'Secure payment',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Patient/Receiver: $patientName',
                    style: AppTextStyles.bodyMedium,
                  ),
                  Text(
                    address,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              child: Column(
                children: [
                  _row('Subtotal', subtotal),
                  if (discount > 0)
                    _row('Discount', discount, isDiscount: true),
                  _row('Platform commission', platformFee),
                  if (deliveryFee > 0) _row('Delivery Fee', deliveryFee),
                  _row('Tax charges', taxCharges),
                  const Divider(height: 24),
                  _row('Total', totalAmount, isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Iconsax.card,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paymentMethodText,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          paymentMethodDesc,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Iconsax.tick_circle, color: AppColors.primary),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isPaying || isSubmitting ? null : _onProceed,
              child: _isPaying || isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(buttonText),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppCardStyles.sleekCard,
      child: child,
    );
  }

  Widget _row(
    String label,
    double amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                color: isTotal
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            isDiscount
                ? '- ₹${amount.toStringAsFixed(0)}'
                : '₹${amount.toStringAsFixed(0)}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: isDiscount
                  ? AppColors.error
                  : isTotal
                  ? AppColors.primaryAccent
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
