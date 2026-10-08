import 'package:flutter/material.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../providers/auth_provider.dart';
import '../../notifiers/shop_bidding_notifier.dart';
import '../../notifiers/incoming_wholesale_notifier.dart';

class LiveOrdersScreen extends ConsumerStatefulWidget {
  const LiveOrdersScreen({super.key});

  @override
  ConsumerState<LiveOrdersScreen> createState() => _LiveOrdersScreenState();
}

class _LiveOrdersScreenState extends ConsumerState<LiveOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        ref.read(shopBiddingProvider.notifier).connect(user.customerId ?? '');
        ref.read(incomingWholesaleProvider.notifier).fetchOrders(user.customerId ?? '');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final biddingState = ref.watch(shopBiddingProvider);
    final wholesaleState = ref.watch(incomingWholesaleProvider);

    return Scaffold(
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        showBackButton: false,
        title: 'Live Orders',
        subtitle: biddingState.isConnected ? 'Connected to live feed' : 'Connecting...',
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          final user = ref.read(authProvider).user;
          if (user != null) {
            await ref.read(incomingWholesaleProvider.notifier).fetchOrders(user.customerId ?? '');
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radar Section
            Row(
              children: [
                const Icon(Iconsax.radar_2, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Active Bidding', style: AppTextStyles.header.copyWith(fontSize: 20)),
                const Spacer(),
                if (biddingState.isConnected)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (biddingState.activeBids.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.cardPadding * 2),
                decoration: AppCardStyles.sleekCard,
                child: Column(
                  children: [
                    const Icon(Iconsax.clock, size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text('No nearby orders yet.', style: AppTextStyles.bodyMedium),
                    Text('Stay on this screen to catch incoming carts.', style: AppTextStyles.caption, textAlign: TextAlign.center),
                  ],
                ),
              )
            else
              ...biddingState.activeBids.map((bid) => _buildActiveOrderCard(
                    orderId: '#${bid['order_id'].toString().substring(0, 6)}',
                    status: 'Incoming Bid',
                    items: '${bid['items']?.length ?? 0} Items',
                    customer: 'Nearby Customer',
                    time: 'Just now',
                    isFindingDriver: false,
                  )),

            const SizedBox(height: AppSpacing.sectionGap),

            // Wholesale Deliveries
            Text('Incoming Wholesale Deliveries', style: AppTextStyles.header.copyWith(fontSize: 20)),
            const SizedBox(height: 12),
            if (wholesaleState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (wholesaleState.error != null)
              Text('Error loading POs: ${wholesaleState.error}', style: const TextStyle(color: Colors.red))
            else if (wholesaleState.orders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: AppCardStyles.sleekCard,
                child: const Center(child: Text('No incoming wholesale orders')),
              )
            else
              ...wholesaleState.orders.map((po) {
                final dateStr = po.createdAt.isNotEmpty 
                    ? DateFormat('MMM d, h:mm a').format(DateTime.tryParse(po.createdAt) ?? DateTime.now())
                    : 'Pending';
                
                final itemCount = po.items.fold(0, (sum, item) => sum + item.qtyBoxes);
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildIncomingWholesaleCard(
                    poId: '#${po.poId.substring(0, 8)}',
                    status: po.poStatus,
                    distributor: po.distributorName,
                    items: '${po.items.length} Items ($itemCount Boxes total)',
                    eta: dateStr,
                    amount: '₹${po.totalInvoiceAmount.toStringAsFixed(2)}',
                  ),
                );
              }),
              
            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildActiveOrderCard({
    required String orderId,
    required String status,
    required String items,
    required String customer,
    required String time,
    required bool isFindingDriver,
    String? driverName,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order $orderId', style: AppTextStyles.cardTitle),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isFindingDriver ? Colors.orange.withAlpha(25) : Colors.blue.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.caption.copyWith(
                    color: isFindingDriver ? Colors.orange : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: AppColors.divider),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Iconsax.box, size: 20, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Expanded(child: Text(items, style: AppTextStyles.bodyMedium)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Iconsax.user, size: 20, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Text(customer, style: AppTextStyles.caption),
              const Spacer(),
              Text(time, style: AppTextStyles.caption),
            ],
          ),
          if (driverName != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.truck_fast, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('Driver: $driverName', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildIncomingWholesaleCard({
    required String poId,
    required String status,
    required String distributor,
    required String items,
    required String eta,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PO $poId', style: AppTextStyles.cardTitle),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: AppColors.divider),
          Row(
            children: [
              const Icon(Iconsax.shop, size: 20, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  distributor,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                amount,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Iconsax.box, size: 20, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Text(items, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.clock, size: 18, color: AppColors.warning),
                const SizedBox(width: 8),
                Text('ETA: $eta', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
