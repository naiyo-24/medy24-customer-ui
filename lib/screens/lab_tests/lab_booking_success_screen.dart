import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class LabBookingSuccessScreen extends StatelessWidget {
  final String labPhone;

  const LabBookingSuccessScreen({super.key, required this.labPhone});

  Future<void> _callLab() async {
    if (labPhone.isEmpty) return;
    final Uri url = Uri.parse('tel:\$labPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
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
                // Big Checkmark
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.verify,
                    color: AppColors.success,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  "Booking Confirmed!",
                  style: AppTextStyles.header.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 16),
                
                Text(
                  "Your lab test booking has been sent to the lab. They have been notified instantly.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 48),

                // Call Lab Box
                if (labPhone.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(13),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withAlpha(51)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Need to schedule a specific time or ask about fasting?",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _callLab,
                          icon: const Icon(Iconsax.call, color: Colors.white),
                          label: Text("Call Lab Now", style: AppTextStyles.cardTitle.copyWith(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 48),
                
                // Back to Home
                TextButton(
                  onPressed: () {
                    context.go('/home'); // Ensure we return to home correctly
                  },
                  child: Text(
                    "Back to Home",
                    style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
