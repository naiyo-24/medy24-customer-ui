import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/distributor_orders_provider.dart';

class RetailerOrdersTab extends ConsumerWidget {
  const RetailerOrdersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsyncValue = ref.watch(distributorOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ordersAsyncValue.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No orders received yet.', style: AppTextStyles.description));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(distributorOrdersProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(context, ref, order);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, WidgetRef ref, dynamic order) {
    final poId = order['po_id'];
    final status = order['po_status'];
    final total = order['total_invoice_amount'];
    final dateStr = order['created_at'];
    final formattedDate = dateStr != null 
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.parse(dateStr))
        : 'Unknown Date';

    Color statusColor = Colors.orange;
    if (status == 'accepted' || status == 'invoiced') statusColor = Colors.blue;
    if (status == 'dispatched') statusColor = Colors.purple;
    if (status == 'delivered') statusColor = Colors.green;
    if (status == 'cancelled' || status == 'rejected') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('PO ID: ${poId.toString().substring(0, 8)}...', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toString().toUpperCase(),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Shop ID: ${order['shop_id']}', style: AppTextStyles.caption),
            Text('Ordered on: $formattedDate', style: AppTextStyles.caption),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${order['items_count']} items', style: AppTextStyles.bodyMedium),
                Text('₹$total', style: AppTextStyles.header.copyWith(fontSize: 18, color: AppColors.primary)),
              ],
            ),
            if (status != 'delivered' && status != 'cancelled' && status != 'rejected') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showStatusUpdateDialog(context, ref, poId, status),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Update Status'),
                    ),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, WidgetRef ref, String poId, String currentStatus) {
    String? selectedStatus = currentStatus;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Update Order Status', style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: ['placed', 'accepted', 'invoiced', 'dispatched', 'delivered', 'rejected']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase(), style: const TextStyle(fontFamily: 'Lexend'))))
                        .toList(),
                    onChanged: (val) => setState(() => selectedStatus = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontFamily: 'Lexend', color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedStatus != null && selectedStatus != currentStatus) {
                      Navigator.pop(context);
                      try {
                        await ref.read(distributorOrderServiceProvider)!.updateOrderStatus(poId, selectedStatus!);
                        ref.invalidate(distributorOrdersProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Order status updated successfully'), backgroundColor: AppColors.success),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update status: $e'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save', style: TextStyle(fontFamily: 'Lexend', color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
