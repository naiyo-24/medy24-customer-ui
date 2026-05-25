import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: AppCardStyles.sleekCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderId?.substring(0, 8) ?? 'N/A'}',
                  style: AppTextStyles.cardTitle,
                ),
                _buildStatusBadge(order.orderStatus ?? 'unknown'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order.createdAt != null 
                  ? DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt!) 
                  : 'Unknown Date',
              style: AppTextStyles.cardSubtitle,
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${order.totalBillAmount?.toStringAsFixed(2) ?? '0.00'}',
                      style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Payment Mode', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      order.paymentMode?.toUpperCase() ?? 'COD',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${order.items.length} Item(s)',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'broadcast':
        color = Colors.orange;
        text = 'PENDING ASSIGNMENT';
        break;
      case 'accepted':
        color = Colors.blue;
        text = 'ACCEPTED';
        break;
      case 'packing':
        color = Colors.indigo;
        text = 'PACKING';
        break;
      case 'out_for_delivery':
        color = Colors.purple;
        text = 'OUT FOR DELIVERY';
        break;
      case 'delivered':
        color = AppColors.success;
        text = 'DELIVERED';
        break;
      case 'cancelled':
        color = AppColors.error;
        text = 'CANCELLED';
        break;
      default:
        color = Colors.grey;
        text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
