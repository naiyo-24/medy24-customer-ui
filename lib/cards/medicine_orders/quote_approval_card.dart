// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../models/order.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/razorpay_payment_service.dart';

class QuoteApprovalCard extends ConsumerStatefulWidget {
  final OrderModel order;
  final QuoteModel quote;

  const QuoteApprovalCard({
    super.key,
    required this.order,
    required this.quote,
  });

  @override
  ConsumerState<QuoteApprovalCard> createState() => _QuoteApprovalCardState();
}

class _QuoteApprovalCardState extends ConsumerState<QuoteApprovalCard> {
  String _paymentMode = 'cod';
  bool _isProcessing = false;
  final RazorpayPaymentService _razorpayService = RazorpayPaymentService();

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  Future<void> _handleAcceptAndProceed(String quoteId) async {
    setState(() => _isProcessing = true);
    try {
      OrderModel? updatedOrder;
      
      // If already pending payment, just re-initiate Razorpay, don't approve again
      if (widget.order.orderStatus == 'pending_payment') {
        updatedOrder = widget.order;
      } else {
        updatedOrder = await ref.read(orderProvider.notifier).approveQuote(widget.order.orderId ?? '', quoteId, _paymentMode);
      }
      
      if (updatedOrder != null && _paymentMode == 'online') {
        // Initiate Razorpay payment
        final rpResponse = await ref.read(orderProvider.notifier).initiateOnlinePayment(updatedOrder.orderId!);
        
        if (rpResponse == null || rpResponse['razorpay_order_id'] == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to initiate razorpay order')));
          setState(() => _isProcessing = false);
          return;
        }

        final razorpayReady = await _razorpayService.ensureReady(
          onSuccess: (PaymentSuccessResponse response) async {
            final success = await ref.read(orderProvider.notifier).verifyOnlinePayment(
              orderId: updatedOrder!.orderId!,
              razorpayPaymentId: response.paymentId ?? '',
              razorpayOrderId: response.orderId ?? '',
              razorpaySignature: response.signature ?? '',
            );
            if (!mounted) return;
            setState(() => _isProcessing = false);
            if (!success) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment verification failed')));
            }
          },
          onError: (PaymentFailureResponse response) {
            if (!mounted) return;
            setState(() => _isProcessing = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.message ?? 'Payment failed.')));
          },
        );

        if (!razorpayReady) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Razorpay is not loaded.')));
          setState(() => _isProcessing = false);
          return;
        }

        final double amount = (rpResponse['amount'] is int)
            ? (rpResponse['amount'] as int).toDouble()
            : (rpResponse['amount'] ?? 0.0);
        final amountPaise = (amount * 100).round();

        final user = ref.read(profileProvider).user ?? ref.read(authProvider).user;

        try {
          await _razorpayService.openCheckout(
            orderId: rpResponse['razorpay_order_id'],
            amountPaise: amountPaise,
            contact: user?.phoneNumber ?? '',
            email: user?.email ?? '',
            name: user?.fullName ?? '',
            description: 'Prescription Order',
          );
        } on MissingPluginException {
          if (!mounted) return;
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Razorpay plugin unavailable.')));
        }
      } else {
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.order.orderStatus != 'awaiting_customer_approval' && widget.order.orderStatus != 'pending_payment') return const SizedBox.shrink();
    if (widget.order.quotes.isEmpty) return const SizedBox.shrink();

    return _buildQuoteItem(widget.quote);
  }

  Widget _buildQuoteItem(QuoteModel quote) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withAlpha(76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Quote from ${quote.shopName ?? "Pharmacy"}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Bill Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                if (quote.items.isNotEmpty) ...[
                  ...quote.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.medicine.medicineName ?? "Unknown"}',
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),  
                        Text(
                          '₹${(item.quantity * (item.medicine.finalPrice ?? item.medicine.mrp ?? 0.0)).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  )),
                  const Divider(),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Bill Amount:'),
                    Text(
                      '₹${((quote.itemTotal ?? 0.0) + (widget.order.platformFee ?? 0.0) + (widget.order.taxes ?? 0.0) + (widget.order.deliveryFee ?? 0.0)).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment Mode Selection
          const Text(
            'Select Payment Method:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('COD', style: TextStyle(fontSize: 12)),
                  value: 'cod',
                  groupValue: _paymentMode,
                  onChanged: (val) {
                    if (val != null) setState(() => _paymentMode = val);
                  },
                  contentPadding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  activeColor: Colors.blue,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Pay Online', style: TextStyle(fontSize: 12)),
                  value: 'online',
                  groupValue: _paymentMode,
                  onChanged: (val) {
                    if (val != null) setState(() => _paymentMode = val);
                  },
                  contentPadding: EdgeInsets.zero,
                  visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                  activeColor: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _handleAcceptAndProceed(quote.quoteId ?? ''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isProcessing 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Accept Quote'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}