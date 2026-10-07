import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state_widget.dart';
import '../../services/procurement_service.dart';
import '../../providers/auth_provider.dart';

final procurementHistoryProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user?.token == null) return [];
  return await ProcurementService.getHistory(user!.token!);
});

class DistributorPoHistoryScreen extends ConsumerWidget {
  const DistributorPoHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(procurementHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Procurement Orders', style: AppTextStyles.cardTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: historyAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.refresh(procurementHistoryProvider),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const EmptyStateWidget(
                      title: 'No Procurement Orders',
                      subtitle: 'You have not placed any orders to manufacturers yet.',
                      icon: Iconsax.box,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(procurementHistoryProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return _buildOrderCard(order);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final manufacturer = order['manufacturer'];
    final items = order['items'] as List<dynamic>? ?? [];
    
    DateTime? createdAt;
    if (order['createdAt'] != null && order['createdAt'].toString().isNotEmpty) {
      createdAt = DateTime.tryParse(order['createdAt']);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order['dpoId']?.toString().substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order['dpoStatus']?.toString().toUpperCase() ?? 'PLACED',
                    style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Manufacturer: ${manufacturer?['companyName'] ?? 'Unknown'}',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
            if (createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Placed on: ${DateFormat('MMM dd, yyyy - hh:mm a').format(createdAt)}',
                style: AppTextStyles.caption,
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${items.length} Items', style: AppTextStyles.bodyMedium),
                Text(
                  '₹${order['totalInvoiceAmount']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
