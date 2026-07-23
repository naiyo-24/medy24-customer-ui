import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../cards/medicine_orders/quote_approval_card.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final matchingOrders = orderState.orders
        .where((o) => o.orderId == widget.orderId)
        .toList();
    final order = matchingOrders.isNotEmpty ? matchingOrders.first : null;

    if (order == null) {
      return const Scaffold(
        body: Center(child: Text("Order not found or still loading...")),
      );
    }

    // Extract Customer Location
    final customerLat = double.tryParse(
      order.deliveryAddress?['lat']?.toString() ?? '22.5726',
    );
    final customerLng = double.tryParse(
      order.deliveryAddress?['lng']?.toString() ?? '88.3639',
    );
    final customerLocation = LatLng(
      customerLat ?? 22.5726,
      customerLng ?? 88.3639,
    );

    // Pharmacy Location (actual from order if available, else slight offset from customer)
    final pharmacyLocation = LatLng(
      order.shopLat ?? (customerLocation.latitude - 0.015),
      order.shopLng ?? (customerLocation.longitude + 0.015),
    );

    // Determine Map Bounds to fit both points
    final bounds = LatLngBounds.fromPoints([
      customerLocation,
      pharmacyLocation,
    ]);

    // Active Status mapping
    final isDispatched =
        order.orderStatus == 'packing' ||
        order.orderStatus == 'finding_driver' ||
        order.orderStatus == 'out_for_delivery' ||
        order.orderStatus == 'delivered';

    return PopScope(
      canPop: context.canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          title: Text(
            'Track Order',
            style: AppTextStyles.header.copyWith(fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // --- 1. Live Map Section ---
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: customerLocation,
                    initialZoom: 13.0,
                    initialCameraFit: CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(50),
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.medy24.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [pharmacyLocation, customerLocation],
                          color: AppColors.primary,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        // Pharmacy Marker
                        Marker(
                          point: pharmacyLocation,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.local_pharmacy,
                            color: AppColors.primary,
                            size: 35,
                          ),
                        ),
                        // Customer Marker
                        Marker(
                          point: customerLocation,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.error,
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- 1.5 Pharmacy Details ---
              if (order.shopName != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: AppCardStyles.sleekCard,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: AppColors.primary.withAlpha(20),
                        child: const Icon(
                          Icons.local_pharmacy,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fulfilling Pharmacy',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.shopName!,
                              style: AppTextStyles.header.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (order.shopPhone != null)
                        IconButton(
                          icon: const Icon(
                            Icons.call,
                            color: AppColors.success,
                          ),
                          onPressed: () {},
                        ),
                    ],
                  ),
                ),

              // --- 2. Rider Details & OTP ---
              if (isDispatched)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: AppCardStyles.sleekCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.primary.withAlpha(20),
                            child: const Icon(
                              Icons.delivery_dining,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.riderName ?? 'Assigning Rider...',
                                  style: AppTextStyles.header.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${order.vehicleModel ?? ''} • ${order.vehicleNumber ?? ''}',
                                  style: AppTextStyles.description,
                                ),
                              ],
                            ),
                          ),
                          if (order.riderPhone != null)
                            IconButton(
                              icon: const Icon(
                                Icons.call,
                                color: AppColors.success,
                              ),
                              onPressed: () {
                                // Direct call intent
                              },
                            ),
                        ],
                      ),
                      if (order.deliveryOtp != null) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Delivery OTP',
                              style: AppTextStyles.cardSubtitle,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.deliveryOtp!,
                                style: AppTextStyles.header.copyWith(
                                  color: AppColors.primary,
                                  letterSpacing: 4.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please share this OTP with the rider at the time of delivery to receive your package.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // --- 3. Order Status Timeline ---
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: AppCardStyles.sleekCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Status',
                      style: AppTextStyles.header.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    _buildStatusRow(
                      'Order Placed',
                      order.createdAt != null,
                      true,
                    ),
                    _buildStatusRow(
                      'Accepted by Pharmacy',
                      order.acceptedAt != null || isDispatched,
                      true,
                    ),
                    _buildStatusRow(
                      'Out for Delivery',
                      order.orderStatus == 'out_for_delivery' ||
                          order.orderStatus == 'delivered',
                      true,
                    ),
                    _buildStatusRow(
                      'Delivered',
                      order.orderStatus == 'delivered',
                      false,
                    ),
                  ],
                ),
              ),

              // --- 3.5 Quote Approval (If Applicable) ---
              if ((order.orderStatus == 'pending' ||
                      order.orderStatus == 'searching_for_pharmacy' ||
                      order.orderStatus == 'awaiting_customer_approval' ||
                      order.orderStatus == 'pending_payment') &&
                  order.quotes.isNotEmpty)
                ...order.quotes.map(
                  (quote) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: QuoteApprovalCard(order: order, quote: quote),
                  ),
                ),

              if (order.items.isNotEmpty)
                () {
                  final dynamicItemTotal = order.items.fold<double>(
                    0.0,
                    (sum, item) =>
                        sum +
                        (item.quantity *
                            (item.medicine.finalPrice ??
                                item.medicine.mrp ??
                                0.0)),
                  );
                  final dynamicGrandTotal =
                      dynamicItemTotal +
                      (order.taxes ?? 0.0) +
                      (order.platformFee ?? 0.0) +
                      (order.deliveryFee ?? 0.0);

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: AppCardStyles.sleekCard,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Itemized Bill',
                          style: AppTextStyles.header.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        ...order.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.medicine.medicineName ?? "Unknown"}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Text(
                                  '₹${((item.quantity) * (item.medicine.finalPrice ?? 0.0)).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Item Total',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            Text('₹${dynamicItemTotal.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Taxes & Fees',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            Text(
                              '₹${((order.taxes ?? 0.0) + (order.platformFee ?? 0.0) + (order.deliveryFee ?? 0.0)).toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Grand Total',
                              style: AppTextStyles.header.copyWith(
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '₹${dynamicGrandTotal.toStringAsFixed(2)}',
                              style: AppTextStyles.header.copyWith(
                                color: AppColors.primary,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }(),

              // --- 5. Advertisement Banner ---
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get 50% OFF on Lab Tests!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Book a full body checkup today.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ElevatedButton(
                        onPressed: () => context.push('/lab-test-list'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Book Now'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String title, bool isCompleted, bool showLine) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.success : Colors.grey.shade300,
                border: Border.all(
                  color: isCompleted ? AppColors.success : Colors.grey.shade400,
                  width: 2,
                ),
              ),
            ),
            if (showLine)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? AppColors.success : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            color: isCompleted
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
