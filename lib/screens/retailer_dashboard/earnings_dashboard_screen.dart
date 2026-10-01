import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../providers/auth_provider.dart';
import '../../notifiers/retailer_analytics_notifier.dart';

class EarningsDashboardScreen extends ConsumerStatefulWidget {
  const EarningsDashboardScreen({super.key});

  @override
  ConsumerState<EarningsDashboardScreen> createState() => _EarningsDashboardScreenState();
}

class _EarningsDashboardScreenState extends ConsumerState<EarningsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(retailerAnalyticsProvider.notifier).fetchAnalytics(user.customerId ?? '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(retailerAnalyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        showBackButton: false,
        title: 'Earnings',
        subtitle: 'Track your shop\'s performance',
      ),
      body: _buildBody(analyticsState),
    );
  }

  Widget _buildBody(RetailerAnalyticsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Text(
          'Error loading analytics: ${state.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final data = state.data;
    if (data == null) {
      return const Center(child: Text('No analytics data available.'));
    }

    final kpis = data['kpis'] ?? {};
    final recentOrders = data['recent_orders'] as List<dynamic>? ?? [];

    final NumberFormat currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Grid
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Total Revenue',
                  value: currencyFormat.format(kpis['total_revenue'] ?? 0),
                  icon: Iconsax.wallet_2,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  title: 'Net Balance',
                  value: currencyFormat.format(kpis['net_balance'] ?? 0),
                  icon: Iconsax.bank,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildKpiCard(
                  title: 'Total Orders',
                  value: '${kpis['total_orders'] ?? 0}',
                  icon: Iconsax.box,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKpiCard(
                  title: 'Total Earnings',
                  value: currencyFormat.format(kpis['total_earnings'] ?? 0),
                  icon: Iconsax.shop,
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // Recent Transactions Placeholder
          Text('Recent Orders', style: AppTextStyles.cardTitle),
          const SizedBox(height: 12),
          if (recentOrders.isEmpty)
            const Center(child: Text('No recent orders'))
          else
            Container(
              decoration: AppCardStyles.sleekCard,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: recentOrders.asMap().entries.map((entry) {
                    final index = entry.key;
                    final order = entry.value;
                    
                    final dateStr = order['created_at'] != null 
                        ? DateFormat('MMM d, y, h:mm a').format(DateTime.parse(order['created_at']))
                        : 'Unknown Date';

                    final isLast = index == recentOrders.length - 1;
                    
                    return Column(
                      children: [
                        _buildTransactionTile(
                          title: 'Order ${order['order_status'] ?? ''} #${order['order_id']?.toString().substring(0, 6)}',
                          date: dateStr,
                          amount: '+ ${currencyFormat.format(order['total_bill_amount'] ?? 0)}',
                          isCredit: true,
                        ),
                        if (!isLast) const Divider(height: 1, thickness: 1, color: AppColors.divider),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.header.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildTransactionTile({
    required String title,
    required String date,
    required String amount,
    required bool isCredit,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCredit ? Colors.green.withAlpha(25) : Colors.red.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isCredit ? Iconsax.arrow_down : Iconsax.arrow_up_2,
          color: isCredit ? Colors.green : Colors.red,
          size: 20,
        ),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(date, style: AppTextStyles.caption),
      trailing: Text(
        amount,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isCredit ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardPadding, vertical: 8),
    );
  }
}
