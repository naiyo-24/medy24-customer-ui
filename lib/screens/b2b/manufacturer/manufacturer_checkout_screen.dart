import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../theme/app_theme.dart';
import '../../../models/manufacturer_models.dart';
import '../../../notifiers/manufacturer_cart_notifier.dart';
import '../../../services/api_url.dart';
import '../../../services/procurement_service.dart';
import '../../../providers/auth_provider.dart';

class ManufacturerCheckoutScreen extends ConsumerStatefulWidget {
  final ManufacturerModel manufacturer;
  final List<ManufacturerMedicineModel> catalog; // Passed to calculate total correctly

  const ManufacturerCheckoutScreen({
    super.key,
    required this.manufacturer,
    required this.catalog,
  });

  @override
  ConsumerState<ManufacturerCheckoutScreen> createState() => _ManufacturerCheckoutScreenState();
}

class _ManufacturerCheckoutScreenState extends ConsumerState<ManufacturerCheckoutScreen> {
  late Razorpay _razorpay;
  bool _isLoading = false;

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

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final cartState = ref.read(manufacturerCartProvider);
    final cartItems = widget.catalog.where((m) => cartState.quantities.containsKey(m.id)).toList();
    
    final items = cartItems.map((item) => {
      'medicine_id': item.id,
      'qty_cartons': cartState.quantities[item.id] ?? 1,
      'ptd': item.ptr,
      'batch_number': item.batchNumber,
    }).toList();

    final user = ref.read(authProvider).user;
    if (user?.token != null) {
      setState(() => _isLoading = true);
      try {
        await ProcurementService.checkout(user!.token!, widget.manufacturer.id, items);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Successful! PO Placed.', style: AppTextStyles.caption.copyWith(color: Colors.white)), backgroundColor: AppColors.success)
        );
        ref.read(manufacturerCartProvider.notifier).clearCart();
        context.go('/distributor-dashboard');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving order: $e', style: AppTextStyles.caption.copyWith(color: Colors.white)), backgroundColor: AppColors.error)
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}', style: AppTextStyles.caption.copyWith(color: Colors.white)), backgroundColor: AppColors.error),
    );
    setState(() => _isLoading = false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle Wallet (Paytm, etc.)
  }

  Future<void> _startPayment(double amount) async {
    setState(() => _isLoading = true);
    
    // In a real implementation, you would call the backend to create a Razorpay Order ID here.
    // For demo purposes, we will initiate Razorpay directly.
    try {
      var options = {
        'key': ApiUrl.razorpayKeyId,
        'amount': (amount * 100).toInt(), // amount in paisa
        'name': 'Medy24 B2B Procurement',
        'description': 'Purchase Order to ${widget.manufacturer.name}',
        'prefill': {
          'contact': '9876543210',
          'email': 'distributor@example.com'
        },
        'theme': {
          'color': '#115C52' // AppColors.primary
        }
      };

      _razorpay.open(options);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initiating payment: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(manufacturerCartProvider);
    final totalValue = cartState.calculateTotalValue(widget.catalog);
    
    // Filter catalog to only items in cart
    final cartItems = widget.catalog.where((m) => cartState.quantities.containsKey(m.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Order', style: AppTextStyles.cardTitle),
      ),
      backgroundColor: AppColors.background,
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty', style: AppTextStyles.description))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final qty = cartState.quantities[item.id] ?? 0;
                      final itemTotal = item.ptr * qty;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.medication, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('₹${item.ptr} × $qty boxes', style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              Text('₹${itemTotal.toStringAsFixed(2)}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal', style: AppTextStyles.bodyMedium),
                            Text('₹${totalValue.toStringAsFixed(2)}', style: AppTextStyles.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('GST (12%)', style: AppTextStyles.bodyMedium),
                            Text('₹${(totalValue * 0.12).toStringAsFixed(2)}', style: AppTextStyles.bodyMedium),
                          ],
                        ),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Payable', style: AppTextStyles.cardTitle),
                            Text('₹${(totalValue * 1.12).toStringAsFixed(2)}', style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : () => _startPayment(totalValue * 1.12),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Pay & Place Order', style: TextStyle(fontFamily: 'Lexend', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
