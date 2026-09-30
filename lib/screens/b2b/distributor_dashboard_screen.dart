import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class DistributorDashboardScreen extends ConsumerWidget {
  const DistributorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Distributor Dashboard', style: AppTextStyles.cardTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text('Welcome, ${user?.fullName ?? 'Distributor'}', style: AppTextStyles.header),
            const SizedBox(height: 8),
            Text('Manage your inventory and orders here.', style: AppTextStyles.description),
          ],
        ),
      ),
    );
  }
}
