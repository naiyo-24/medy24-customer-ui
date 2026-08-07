import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../models/lab_package.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lab_test_provider.dart';
import '../../services/razorpay_payment_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class LabCheckoutScreen extends ConsumerStatefulWidget {
  final LabPackage lab;

  const LabCheckoutScreen({super.key, required this.lab});

  @override
  ConsumerState<LabCheckoutScreen> createState() => _LabCheckoutScreenState();
}

class _LabCheckoutScreenState extends ConsumerState<LabCheckoutScreen> {
  bool _isBooking = false;
  String _paymentMode = 'cod';
  final RazorpayPaymentService _razorpayService = RazorpayPaymentService();

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    setState(() {
      _isBooking = true;
    });

    try {
      final userState = ref.read(authProvider);
      final customerId = userState.user?.customerId;
      
      if (customerId == null) {
        throw Exception("User not logged in");
      }

      final payload = {
        "customer_id": customerId,
        "lab_id": widget.lab.labId,
        "patient_name": userState.user?.fullName?.isNotEmpty == true ? userState.user!.fullName : "Self",
        "patient_phone": userState.user?.phoneNumber ?? "Unknown",
        "is_home_collection": true,
        "booked_tests": widget.lab.matchedTests.map((t) => {
          "test_id": t.testId,
          "test_name": t.testName,
          "price": t.price
        }).toList(),
        "total_price": widget.lab.totalPrice,
        "payment_mode": _paymentMode
      };

      final service = ref.read(labTestServiceProvider);
      final response = await service.bookLabTests(payload);
      
      final labPhone = response.data['lab_phone'] ?? "";
      final bookingId = response.data['booking_id'];
      
      if (_paymentMode == 'online' && bookingId != null) {
        // Create order in backend
        final rpResponse = await _razorpayService.createOrder(bookingId, widget.lab.totalPrice);
        
        if (rpResponse.data['status'] != 'success') {
          throw Exception(rpResponse.data['detail'] ?? 'Failed to initiate razorpay order');
        }
        
        final razorpayReady = await _razorpayService.ensureReady(
          onSuccess: (PaymentSuccessResponse paymentResponse) async {
            try {
              final verifyRes = await _razorpayService.verifyPayment(
                paymentResponse.orderId ?? '',
                paymentResponse.paymentId ?? '',
                paymentResponse.signature ?? '',
              );
              
              if (verifyRes.data['status'] == 'success') {
                if (!mounted) return;
                ref.read(labTestProvider.notifier).clearSelections();
                context.pushReplacement('/lab-booking-waiting/$bookingId', extra: labPhone);
              } else {
                throw Exception("Payment verification failed");
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment verification failed: \$e')));
                setState(() => _isBooking = false);
              }
            }
          },
          onError: (PaymentFailureResponse failureResponse) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failureResponse.message ?? 'Payment failed')));
              setState(() => _isBooking = false);
            }
          },
        );

        if (!razorpayReady) {
          throw Exception("Razorpay not loaded");
        }

        final amountPaise = (widget.lab.totalPrice * 100).round();
        
        await _razorpayService.openCheckout(
          orderId: rpResponse.data['razorpay_order_id'],
          amountPaise: amountPaise,
          contact: userState.user?.phoneNumber ?? '',
          email: userState.user?.email ?? '',
          name: userState.user?.fullName ?? '',
          description: 'Lab Test Booking',
        );
      } else {
        if (mounted) {
          ref.read(labTestProvider.notifier).clearSelections();
          context.pushReplacement('/lab-booking-waiting/$bookingId', extra: labPhone);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error confirming booking: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Review Booking',
        subtitle: 'Finalize your lab test booking',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Lab Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(13),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withAlpha(51)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.hospital, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text("Selected Lab", style: AppTextStyles.cardSubtitle),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(widget.lab.labName, style: AppTextStyles.cardTitle),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bill Summary
            Text("Bill Summary", style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ...widget.lab.matchedTests.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(t.testName, style: AppTextStyles.bodyMedium)),
                            Text("₹${t.price.toStringAsFixed(0)}", style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      )),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text("Total Amount", style: AppTextStyles.bodyMedium)),
                      Text("₹${widget.lab.totalPrice.toStringAsFixed(0)}", 
                        style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Mode
            Text("Payment Method", style: AppTextStyles.cardTitle),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _paymentMode == 'cod' ? AppColors.primary : Colors.grey.withAlpha(51)),
                    ),
                    child: RadioListTile<String>(
                      title: Text("COD", style: AppTextStyles.bodyMedium),
                      subtitle: Text("Pay at collection", style: AppTextStyles.caption),
                      value: 'cod',
                      // ignore: deprecated_member_use
                      groupValue: _paymentMode,
                      // ignore: deprecated_member_use
                      onChanged: (val) {
                        if (val != null) setState(() => _paymentMode = val);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      activeColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _paymentMode == 'online' ? AppColors.primary : Colors.grey.withAlpha(51)),
                    ),
                    child: RadioListTile<String>(
                      title: Text("Online", style: AppTextStyles.bodyMedium),
                      subtitle: Text("Pay instantly via Razorpay", style: AppTextStyles.caption),
                      value: 'online',
                      // ignore: deprecated_member_use
                      groupValue: _paymentMode,
                      // ignore: deprecated_member_use
                      onChanged: (val) {
                        if (val != null) setState(() => _paymentMode = val);
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      activeColor: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isBooking ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isBooking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Confirm Booking",
                        style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
