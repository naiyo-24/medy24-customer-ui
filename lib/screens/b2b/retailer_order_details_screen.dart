import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';

class RetailerOrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const RetailerOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final poId = order['po_id'] ?? 'Unknown ID';
    final status = order['po_status'] ?? 'unknown';
    final total = order['total_invoice_amount'] ?? 0;
    final dateStr = order['created_at'];
    final formattedDate = dateStr != null 
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.parse(dateStr))
        : 'Unknown Date';
    final shopId = order['shop_id'] ?? 'Unknown Shop';

    Color statusColor = Colors.orange;
    if (status == 'accepted' || status == 'invoiced') statusColor = Colors.blue;
    if (status == 'dispatched') statusColor = Colors.purple;
    if (status == 'delivered') statusColor = Colors.green;
    if (status == 'cancelled' || status == 'rejected') statusColor = Colors.red;

    final items = order['items'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order $poId'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              decoration: AppCardStyles.sleekCard,
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Status', style: AppTextStyles.bodyMedium),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status.toString().toUpperCase(),
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow('Shop ID', shopId.toString()),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Date', formattedDate),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Total Amount', '₹$total', isTotal: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Order Items Section
            const Text('Order Items', style: AppTextStyles.subHeader),
            const SizedBox(height: 12),
            if (items.isEmpty)
              const Text('No items found in this order.', style: AppTextStyles.description)
            else
              ...items.map((item) => _buildOrderItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: isTotal 
                ? AppTextStyles.cardTitle.copyWith(color: AppColors.primary)
                : AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(dynamic item) {
    final qty = item['qty_boxes'] ?? 0;
    final ptr = item['ptr'] ?? 0.0;
    final name = item['medicine_name'] ?? 'Medicine ID: ${item['inventory_id'] ?? 'Unknown'}';
    final batch = item['batch_number'] ?? 'N/A';
    
    // safe cast to double/num
    num quantity = qty is num ? qty : 0;
    num price = ptr is num ? ptr : 0.0;
    final total = quantity * price;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppCardStyles.sleekCard,
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
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
                Text(name, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Batch: $batch', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text('$quantity boxes @ ₹$price', style: AppTextStyles.caption),
                    ),
                    const SizedBox(width: 8),
                    Text('₹${total.toStringAsFixed(2)}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
