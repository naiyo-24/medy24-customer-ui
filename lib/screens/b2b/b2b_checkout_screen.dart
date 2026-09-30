import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../notifiers/b2b_cart_notifier.dart';
import '../../notifiers/b2b_checkout_notifier.dart';
import '../../theme/app_theme.dart';

class B2bCheckoutScreen extends ConsumerStatefulWidget {
  const B2bCheckoutScreen({super.key});

  @override
  ConsumerState<B2bCheckoutScreen> createState() => _B2bCheckoutScreenState();
}

class _B2bCheckoutScreenState extends ConsumerState<B2bCheckoutScreen> {
  String _selectedPaymentTerm = 'prepaid';
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful!', style: AppTextStyles.caption.copyWith(color: Colors.white)), backgroundColor: AppColors.success)
    );
    ref.read(b2bCheckoutProvider.notifier).resetState();
    context.go('/b2b-orders'); 
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}', style: AppTextStyles.caption.copyWith(color: Colors.white)), backgroundColor: AppColors.error),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle Wallet (Paytm, etc.)
  }

  void _launchRazorpay(Map<String, dynamic> config) {
    var options = {
      'key': config['keyId'],
      'amount': config['amountInPaise'], 
      'name': 'Medy24 Wholesale',
      'description': 'Purchase Order: ${config['poId']}',
      'order_id': config['razorpayOrderId'],
      'prefill': {
        'contact': '9876543210', 
        'email': 'shop@example.com'
      },
      'theme': {
        'color': '#0C9359' // Maps roughly to AppColors.primary
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(b2bCartProvider);
    final checkoutState = ref.watch(b2bCheckoutProvider);

    ref.listen<B2BCheckoutState>(b2bCheckoutProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!, style: AppTextStyles.caption.copyWith(color: Colors.white)), backgroundColor: AppColors.error)
        );
      }
      if (next.razorpayConfig != null) {
        _launchRazorpay(next.razorpayConfig!);
      }
      if (next.successfulPoId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Credit Order Placed!', style: AppTextStyles.caption.copyWith(color: Colors.white)), backgroundColor: AppColors.success)
        );
        context.go('/b2b-orders');
      }
    });

    final subtotal = cartState.totalEstimatedPrice;
    final gstTotal = subtotal * 0.12; 
    final finalTotal = subtotal + gstTotal;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Checkout', style: AppTextStyles.cardTitle), 
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: cartState.isLoading || checkoutState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                // Financial Summary
                Container(
                  decoration: AppCardStyles.sleekCard,
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Summary', style: AppTextStyles.cardTitle),
                      const SizedBox(height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total PTR Value', style: AppTextStyles.bodyMedium), Text('₹${subtotal.toStringAsFixed(2)}', style: AppTextStyles.bodyMedium)]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('CGST (6%)', style: AppTextStyles.bodyMedium), Text('₹${(gstTotal / 2).toStringAsFixed(2)}', style: AppTextStyles.bodyMedium)]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('SGST (6%)', style: AppTextStyles.bodyMedium), Text('₹${(gstTotal / 2).toStringAsFixed(2)}', style: AppTextStyles.bodyMedium)]),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(color: AppColors.divider),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Invoice', style: AppTextStyles.cardTitle),
                          Text('₹${finalTotal.toStringAsFixed(2)}', style: AppTextStyles.cardTitle.copyWith(color: AppColors.primaryAccent)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment Terms
                Text('Payment Terms', style: AppTextStyles.cardTitle),
                const SizedBox(height: 8),
                Container(
                  decoration: AppCardStyles.sleekCard,
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: Text('Prepaid (Online Payment)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text('Pay instantly via UPI, NetBanking, or Card', style: AppTextStyles.caption),
                        value: 'prepaid',
                        groupValue: _selectedPaymentTerm,
                        activeColor: AppColors.primary,
                        onChanged: (value) => setState(() => _selectedPaymentTerm = value.toString()),
                      ),
                      const Divider(height: 1, color: AppColors.divider),
                      RadioListTile<String>(
                        title: Text('Net-30 (Credit)', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text('Subject to your approved credit limit', style: AppTextStyles.caption),
                        value: 'net_30',
                        groupValue: _selectedPaymentTerm,
                        activeColor: AppColors.primary,
                        onChanged: (value) => setState(() => _selectedPaymentTerm = value.toString()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppColors.primaryAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.borderRadius)),
          ),
          onPressed: checkoutState.isLoading || finalTotal <= 0
              ? null
              : () {
                  ref.read(b2bCheckoutProvider.notifier).checkoutCart(_selectedPaymentTerm);
                },
          child: Text(
            'Confirm & Pay ₹${finalTotal.toStringAsFixed(2)}',
            style: AppTextStyles.cardTitle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
