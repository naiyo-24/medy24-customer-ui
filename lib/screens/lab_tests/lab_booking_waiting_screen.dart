import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../providers/lab_test_provider.dart';

class LabBookingWaitingScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String labPhone;

  const LabBookingWaitingScreen({
    super.key,
    required this.bookingId,
    required this.labPhone,
  });

  @override
  ConsumerState<LabBookingWaitingScreen> createState() => _LabBookingWaitingScreenState();
}

class _LabBookingWaitingScreenState extends ConsumerState<LabBookingWaitingScreen> {
  Timer? _timer;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    // Check every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    try {
      final service = ref.read(labTestServiceProvider);
      // Ensure we have a getLabBookingDetails endpoint implemented
      final response = await service.getLabBookingDetails(widget.bookingId);
      final status = (response.data['booking_status'] as String?)?.toLowerCase() ?? '';

      if (status == 'confirmed' || status == 'accepted') {
        _timer?.cancel();
        if (mounted) {
          context.pushReplacement('/lab-booking-success', extra: widget.labPhone);
        }
      } else if (status == 'cancelled' || status == 'rejected') {
        _timer?.cancel();
        if (mounted) {
          setState(() {
            _isChecking = false;
          });
          _showRejectionDialog();
        }
      }
    } catch (e) {
      debugPrint("Error checking booking status: \$e");
    }
  }

  void _showRejectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Booking Not Accepted", style: AppTextStyles.cardTitle),
        content: Text(
          "Sorry, the lab could not accept your booking at this time. Your payment (if any) will be refunded.",
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Go to Home", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isChecking) ...[
                  // If you don't have a lottie file, a simple CircularProgressIndicator is fine
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 32),
                  Text(
                    "Waiting for Lab Approval",
                    style: AppTextStyles.header.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "We've sent your request to the lab. Please wait while they review and accept your booking.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                  ),
                ] else ...[
                  const Icon(Icons.cancel_outlined, color: AppColors.error, size: 80),
                  const SizedBox(height: 24),
                  Text(
                    "Booking Cancelled",
                    style: AppTextStyles.header.copyWith(fontSize: 24),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
