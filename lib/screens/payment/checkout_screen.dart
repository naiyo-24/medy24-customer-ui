import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../models/test_package_booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_test_package_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/charges_provider.dart';
import '../../services/api_url.dart';
import '../../services/razorpay_payment_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../cards/cart/cart_order_pop_up.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final String checkoutType; // 'lab_test' or 'medicine'
  const CheckoutScreen({super.key, this.checkoutType = 'lab_test'});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final RazorpayPaymentService _razorpayService = RazorpayPaymentService();
  bool _isPaying = false;
  String? _medicineOrderId;

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    if (widget.checkoutType == 'lab_test') {
      ref
          .read(bookTestPackageProvider.notifier)
          .setRazorpayPaymentId(response.paymentId ?? '');
      if (!mounted) return;
      setState(() => _isPaying = false);
      _showSuccessAndExit();
    } else if (widget.checkoutType == 'medicine') {
      if (_medicineOrderId != null) {
        final success = await ref
            .read(orderProvider.notifier)
            .verifyOnlinePayment(
              orderId: _medicineOrderId!,
              razorpayPaymentId: response.paymentId ?? '',
              razorpayOrderId: response.orderId ?? '',
              razorpaySignature: response.signature ?? '',
            );
        if (!mounted) return;
        setState(() => _isPaying = false);
        if (success) {
          _showSuccessAndExit();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment verification failed')),
          );
        }
      }
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _isPaying = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message ?? 'Payment failed. Please try again.'),
      ),
    );
  }

  Future<void> _onPayOnline() async {
    try {
      final _ = ApiUrl.razorpayKeyId;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Razorpay configuration error: ${e.toString()}'),
        ),
      );
      return;
    }

    final razorpayReady = await _razorpayService.ensureReady(
      onSuccess: _onPaymentSuccess,
      onError: _onPaymentError,
    );

    if (!razorpayReady) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Razorpay is not loaded. Stop the app completely, then run flutter run.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() => _isPaying = true);
    final user = ref.read(profileProvider).user ?? ref.read(authProvider).user;

    if (widget.checkoutType == 'lab_test') {
      await _payOnlineForLabTest(user);
    } else {
      await _payOnlineForMedicine(user);
    }
  }

  Future<void> _payOnlineForLabTest(dynamic user) async {
    final bookingState = ref.read(bookTestPackageProvider);
    final booking = bookingState.confirmedBooking;

    if (booking == null) {
      setState(() => _isPaying = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No booking found')));
      return;
    }

    BookingResponse? response = bookingState.bookingResponse;
    if (response?.transactionId == null) {
      response = await ref
          .read(bookTestPackageProvider.notifier)
          .placeOnlineBooking(
            customerId: user?.customerId,
            savedAddresses: user?.savedAddresses,
          );
    }

    if (!mounted) return;
    final error = ref.read(bookTestPackageProvider).error;
    if (response == null || response.transactionId == null) {
      setState(() => _isPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to initiate payment')),
      );
      return;
    }

    final amountPaise = (response.totalAmountToBePaid * 100).round();
    try {
      await _razorpayService.openCheckout(
        orderId: response.transactionId!,
        amountPaise: amountPaise,
        contact: booking.patient.phoneNumber,
        email: user?.email ?? '',
        name: booking.patient.fullName,
        description: booking.itemName,
      );
    } on MissingPluginException {
      if (!mounted) return;
      setState(() => _isPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Razorpay plugin unavailable.')),
      );
    }
  }

  Future<void> _payOnlineForMedicine(dynamic user) async {
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

    // Place the order first
    final order = await ref
        .read(orderProvider.notifier)
        .placeOrderFromCart(
          platformFee: summary.platformCharges,
          deliveryFee: summary.deliveryFees,
          taxes: summary.taxes,
          paymentMode: 'online',
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error ?? 'Failed to place order')));
      return;
    }

    _medicineOrderId = order.orderId;

    // Initiate online payment with razorpay
    final rpResponse = await ref
        .read(orderProvider.notifier)
        .initiateOnlinePayment(order.orderId!);
    if (rpResponse == null || rpResponse['razorpay_order_id'] == null) {
      if (!mounted) return;
      setState(() => _isPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to initiate razorpay order')),
      );
      return;
    }

    if (!mounted) return;

    final double amount = (rpResponse['amount'] is int)
        ? (rpResponse['amount'] as int).toDouble()
        : (rpResponse['amount'] ?? 0.0);
    final amountPaise = (amount * 100).round();

    try {
      await _razorpayService.openCheckout(
        orderId: rpResponse['razorpay_order_id'],
        amountPaise: amountPaise,
        contact: user?.phoneNumber ?? '',
        email: user?.email ?? '',
        name: user?.fullName ?? '',
        description: 'Medicine Order',
      );
    } on MissingPluginException {
      if (!mounted) return;
      setState(() => _isPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Razorpay plugin unavailable.')),
      );
    }
  }

  Future<void> _showSuccessAndExit() async {
    String msg = '';
    String trackRoute = '';
    if (widget.checkoutType == 'lab_test') {
      final bookingResponse = ref.read(bookTestPackageProvider).bookingResponse;
      final paymentId = ref.read(bookTestPackageProvider).razorpayPaymentId;
      msg =
          'Booking ID: ${bookingResponse?.bookingId ?? '—'}\n'
          '${paymentId != null ? 'Payment ID: $paymentId\n' : ''}'
          'Your lab test booking is confirmed.';
      final user =
          ref.read(profileProvider).user ?? ref.read(authProvider).user;
      trackRoute = '/my-test-bookings/${user?.customerId ?? ''}';
    } else {
      msg = 'Your medicine order has been placed successfully.';
      trackRoute = '/my-medicine-orders';
    }

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
    if (widget.checkoutType == 'lab_test') {
      return _buildLabTestUI();
    } else {
      return _buildMedicineUI();
    }
  }

  Widget _buildLabTestUI() {
    final bookingState = ref.watch(bookTestPackageProvider);
    final booking = bookingState.confirmedBooking;

    if (booking == null) {
      return const Scaffold(
        appBar: CustomAppBar(
          showBackButton: true,
          title: 'Checkout',
          subtitle: 'Review and pay',
        ),
        body: Center(child: Text('No booking found')),
      );
    }

    final summary = booking.priceSummary;
    return _buildCheckoutLayout(
      title: booking.itemName,
      subtitle: booking.itemSubtitle,
      patientName: booking.patient.fullName,
      address: booking.collectionAddress?.displayAddress ?? '',
      subtotal: summary.subtotal,
      discount: summary.discount,
      platformFee: summary.platformFee,
      taxCharges: summary.taxCharges,
      totalAmount: summary.totalAmount,
      isSubmitting: bookingState.isSubmitting,
      deliveryFee: 0.0,
    );
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
                          'Pay Online',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'UPI, Credit Card, Debit Card',
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
              onPressed: _isPaying || isSubmitting ? null : _onPayOnline,
              child: _isPaying || isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Pay Online · ₹${totalAmount.toStringAsFixed(0)}'),
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
