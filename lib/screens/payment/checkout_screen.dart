import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../providers/book_test_package_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookTestPackageProvider).confirmedBooking;

    if (booking == null) {
      return Scaffold(
        appBar: const CustomAppBar(
          showBackButton: true,
          title: 'Checkout',
          subtitle: 'Review and pay',
        ),
        body: const Center(child: Text('No booking found')),
      );
    }

    final summary = booking.priceSummary;

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
                    booking.itemName,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
                  ),
                  if (booking.itemSubtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      booking.itemSubtitle!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Patient: ${booking.patient.fullName}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  Text(
                    booking.collectionAddress?.displayAddress ?? '',
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
                  _row('Subtotal', summary.subtotal),
                  if (summary.discount > 0)
                    _row('Discount', summary.discount, isDiscount: true),
                  _row('Platform fee', summary.platformFee),
                  _row('Tax charges', summary.taxCharges),
                  const Divider(height: 24),
                  _row('Total', summary.totalAmount, isTotal: true),
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
                          'Online Payment',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'UPI, Card, Net Banking',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Iconsax.tick_circle,
                    color: AppColors.primary,
                  ),
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Payment of ₹${summary.totalAmount.toStringAsFixed(0)} initiated',
                    ),
                  ),
                );
                context.go('/home');
              },
              child: Text(
                'Pay ₹${summary.totalAmount.toStringAsFixed(0)}',
              ),
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

  Widget _row(String label, double amount,
      {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
                color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
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
