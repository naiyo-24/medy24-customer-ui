import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/distributor_orders_provider.dart';
import 'tabs/retailer_orders_tab.dart';
import 'tabs/inventory_alerts_tab.dart';
import 'manufacturer/manufacturer_list_screen.dart';
import 'distributor_profile_screen.dart';

class DistributorDashboardScreen extends ConsumerStatefulWidget {
  const DistributorDashboardScreen({super.key});

  @override
  ConsumerState<DistributorDashboardScreen> createState() => _DistributorDashboardScreenState();
}

class _DistributorDashboardScreenState extends ConsumerState<DistributorDashboardScreen> {
  int _currentIndex = 1;

  final List<Widget> _tabs = [
    const ManufacturerListScreen(),
    const RetailerOrdersTab(),
    const InventoryAlertsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Exit App', style: TextStyle(fontFamily: 'Lexend', fontWeight: FontWeight.bold)),
            content: const Text('Are you sure you want to exit Medy24?', style: TextStyle(fontFamily: 'Lexend')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel', style: TextStyle(fontFamily: 'Lexend', color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Exit', style: TextStyle(fontFamily: 'Lexend', color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.business, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dashboard', style: AppTextStyles.cardTitle),
                Text(user?.fullName ?? 'Distributor Portal', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(
                (user?.fullName ?? 'D').substring(0, 1).toUpperCase(),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DistributorProfileScreen()),
                );
              } else if (value == 'logout') {
                ref.read(authProvider.notifier).logout();
                context.go('/role-selection');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: AppColors.textPrimary, size: 20),
                    SizedBox(width: 12),
                    Text('My Profile', style: TextStyle(fontFamily: 'Lexend')),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent, size: 20),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(fontFamily: 'Lexend', color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
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
      ),
    );
  }
}

