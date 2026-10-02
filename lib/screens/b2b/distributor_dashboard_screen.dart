import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/distributor_orders_provider.dart';

class DistributorDashboardScreen extends ConsumerStatefulWidget {
  const DistributorDashboardScreen({super.key});

  @override
  ConsumerState<DistributorDashboardScreen> createState() => _DistributorDashboardScreenState();
}

class _DistributorDashboardScreenState extends ConsumerState<DistributorDashboardScreen> {
  int _currentIndex = 1;

  final List<Widget> _tabs = [
    const _ProcureStockTab(),
    const _RetailerOrdersTab(),
    const _InventoryAlertsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Distributor Dashboard', style: AppTextStyles.cardTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Profile logic goes here
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Procure Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Retailer POs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventory Alerts',
          ),
        ],
      ),
    );
  }
}

class _ProcureStockTab extends StatelessWidget {
  const _ProcureStockTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.factory, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          Text('Procure Stock (Buyer Mode)', style: AppTextStyles.header),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Browse master catalogs from manufacturers like Cipla and Sun Pharma. (Massive MOQs)', 
              style: AppTextStyles.description,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _RetailerOrdersTab extends ConsumerWidget {
  const _RetailerOrdersTab();

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
                Text('PO ID: ${poId.substring(0, 8)}...', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
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
              title: const Text('Update Order Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: ['placed', 'accepted', 'invoiced', 'dispatched', 'delivered', 'rejected']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                        .toList(),
                    onChanged: (val) => setState(() => selectedStatus = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedStatus != null && selectedStatus != currentStatus) {
                      Navigator.pop(context);
                      try {
                        await ref.read(distributorOrderServiceProvider)!.updateOrderStatus(poId, selectedStatus!);
                        ref.invalidate(distributorOrdersProvider);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}

class _InventoryAlertsTab extends StatelessWidget {
  const _InventoryAlertsTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text('Inventory Alerts', style: AppTextStyles.header),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Quick view of your godown stock: nearing expiry or running below reorder threshold.', 
              style: AppTextStyles.description,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
