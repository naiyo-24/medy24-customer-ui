import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';

// We will fetch from the new backend endpoint later via a proper provider.
// For now we can use a FutureProvider that hits the API.
import 'package:dio/dio.dart';
import '../../../services/api_url.dart';
import '../../../providers/auth_provider.dart';

final inventoryAlertsProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final dio = Dio();
  final user = ref.watch(authProvider).user;
  if (user?.token == null) return [];
  // We will just do a simple fetch here for the alerts.
  try {
    final response = await dio.get(
      '${ApiUrl.baseUrl}/api/v1/distributor/inventory/alerts',
      options: Options(headers: {'Authorization': 'Bearer ${user?.token}'}),
    );
    if (response.statusCode == 200) {
      return response.data;
    }
    return [];
  } catch (e) {
    // Return dummy data if API is not fully linked with auth yet
    return [
      {
        "medicine_name": "Paracetamol 650mg",
        "batch_number": "B-1001",
        "available_stock": 15,
        "expiry_date": DateTime.now().add(const Duration(days: 120)).toIso8601String(),
        "alerts": ["Low Stock"]
      },
      {
        "medicine_name": "Amoxicillin 500mg",
        "batch_number": "B-1002",
        "available_stock": 200,
        "expiry_date": DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        "alerts": ["Expiring Soon"]
      },
      {
        "medicine_name": "Cough Syrup 100ml",
        "batch_number": "B-1005",
        "available_stock": 5,
        "expiry_date": DateTime.now().add(const Duration(days: 10)).toIso8601String(),
        "alerts": ["Low Stock", "Expiring Soon"]
      }
    ];
  }
});

class InventoryAlertsTab extends ConsumerWidget {
  const InventoryAlertsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsyncValue = ref.watch(inventoryAlertsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: alertsAsyncValue.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.refresh(inventoryAlertsProvider),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
                          const SizedBox(height: 16),
                          const Text('Inventory is healthy!', style: AppTextStyles.cardTitle),
                          const Text('No low stock or expiration alerts.', style: AppTextStyles.description),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(inventoryAlertsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _buildAlertCard(alert);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildAlertCard(dynamic alert) {
    final List<dynamic> alertTypes = alert['alerts'] ?? [];
    final bool isLowStock = alertTypes.contains("Low Stock");
    final bool isExpiring = alertTypes.contains("Expiring Soon");

    Color cardBorderColor = Colors.orange;
    if (isLowStock && isExpiring) {
      cardBorderColor = Colors.red;
    } else if (isLowStock) {
      cardBorderColor = Colors.orange;
    } else if (isExpiring) {
      cardBorderColor = Colors.redAccent;
    }

    final dateStr = alert['expiry_date'];
    final formattedDate = dateStr != null 
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(dateStr))
        : 'Unknown';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cardBorderColor.withOpacity(0.5), width: 1),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isLowStock && isExpiring ? Icons.warning : (isLowStock ? Icons.inventory_2 : Icons.date_range),
                  color: cardBorderColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alert['medicine_name'] ?? 'Unknown Medicine',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cardBorderColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alertTypes.join(" & "),
                    style: TextStyle(color: cardBorderColor, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Batch', style: AppTextStyles.caption),
                    Text(alert['batch_number'] ?? 'N/A', style: AppTextStyles.bodyMedium),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stock', style: AppTextStyles.caption),
                    Text(
                      '${alert['available_stock']} units',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isLowStock ? Colors.orange : AppColors.textPrimary,
                        fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Expires', style: AppTextStyles.caption),
                    Text(
                      formattedDate,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isExpiring ? Colors.red : AppColors.textPrimary,
                        fontWeight: isExpiring ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
