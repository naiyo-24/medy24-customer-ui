import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../cards/medicine_orders/quote_approval_card.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/ads/native_ad_widget.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<LatLng> _parabolicPoints = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).startTracking(widget.orderId);
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    )..addListener(() {
        setState(() {}); // Trigger rebuild to draw more points
      });
  }

  void _generateParabolicPoints(LatLng start, LatLng end) {
    if (_parabolicPoints.isNotEmpty) return;
    final points = <LatLng>[];
    
    // Midpoint
    double latM = (start.latitude + end.latitude) / 2;
    double lngM = (start.longitude + end.longitude) / 2;
    
    // Diff
    double dLat = end.latitude - start.latitude;
    double dLng = end.longitude - start.longitude;
    
    // Perpendicular vector for the curve
    double pLat = -dLng;
    double pLng = dLat;
    
    // Control point (0.2 is the curve factor, positive or negative flips the curve)
    double cLat = latM + (pLat * 0.2);
    double cLng = lngM + (pLng * 0.2);
    
    // Generate Bezier curve points
    const int numPoints = 100;
    for (int i = 0; i <= numPoints; i++) {
      double t = i / numPoints;
      double lat = math.pow(1 - t, 2) * start.latitude +
          2 * (1 - t) * t * cLat +
          math.pow(t, 2) * end.latitude;
      double lng = math.pow(1 - t, 2) * start.longitude +
          2 * (1 - t) * t * cLng +
          math.pow(t, 2) * end.longitude;
      points.add(LatLng(lat, lng));
    }
    _parabolicPoints = points;
    _animationController.forward();
  }

  @override
  void dispose() {
    // Only stop tracking if we are actually leaving the tracking state completely
    // but typically it's safe to disconnect when the screen is disposed.
    ref.read(orderProvider.notifier).stopTracking();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final matchingOrders = orderState.orders
        .where((o) => o.orderId == widget.orderId)
        .toList();
    if (matchingOrders.isNotEmpty) {
      final order = matchingOrders.first;
      debugPrint("Order Tracking UI -> orderStatus: ${order.orderStatus}, quotes length: ${order.quotes.length}");
    }
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
    double minLat = math.min(customerLocation.latitude, pharmacyLocation.latitude);
    double maxLat = math.max(customerLocation.latitude, pharmacyLocation.latitude);
    double minLng = math.min(customerLocation.longitude, pharmacyLocation.longitude);
    double maxLng = math.max(customerLocation.longitude, pharmacyLocation.longitude);
    
    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    // Generate parabolic points if not generated yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateParabolicPoints(pharmacyLocation, customerLocation);
    });

    // Calculate visible points based on animation progress
    final int visiblePointCount = (_parabolicPoints.length * _animation.value).round();
    final List<LatLng> currentPolylinePoints = _parabolicPoints.take(visiblePointCount).toList();

    // Active Status mapping
    final isDispatched =
        order.orderStatus == 'packing' ||
        order.orderStatus == 'finding_driver' ||
        order.orderStatus == 'driver_assigned' ||
        order.orderStatus == 'out_for_delivery' ||
        order.orderStatus == 'delivered';

    final isCancelled = order.orderStatus == 'cancelled' || order.orderStatus == 'rejected';

    final isOrderAccepted = order.acceptedAt != null || isDispatched || 
        (order.orderStatus != 'pending' && 
         order.orderStatus != 'bidding' && 
         order.orderStatus != 'searching_for_pharmacy' && 
         order.orderStatus != 'awaiting_customer_approval' && 
         order.orderStatus != 'pending_payment' && 
         order.orderStatus != 'checkout_pending' &&
         !isCancelled);

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
              // --- 1. Live Map Section / Waiting UI ---
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: isCancelled
                    ? Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.error.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cancel_outlined,
                                color: AppColors.error,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Order Cancelled',
                              style: AppTextStyles.header.copyWith(
                                fontSize: 18,
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Text(
                                order.orderStatus == 'rejected' ? 'This order was rejected by the pharmacy.' : 'This order has been cancelled.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.description.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : isOrderAccepted
                        ? GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: customerLocation,
                          zoom: 13.0,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                          Future.delayed(const Duration(milliseconds: 500), () {
                            _mapController?.animateCamera(
                              CameraUpdate.newLatLngBounds(bounds, 50),
                            );
                          });
                        },
                        polylines: {
                          if (currentPolylinePoints.isNotEmpty)
                            Polyline(
                              polylineId: const PolylineId('route'),
                              points: currentPolylinePoints,
                              color: AppColors.primary,
                              width: 4,
                              geodesic: true,
                              patterns: [PatternItem.dash(20), PatternItem.gap(10)], // Optional: dotted line
                            ),
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId('pharmacy'),
                            position: pharmacyLocation,
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                          ),
                          Marker(
                            markerId: const MarkerId('customer'),
                            position: customerLocation,
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                          ),
                        },
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        scrollGesturesEnabled: false,
                        zoomGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                      )
                    : Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: const SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Waiting for Pharmacy',
                              style: AppTextStyles.header.copyWith(
                                fontSize: 18,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Text(
                                'We are finding the best pharmacy to fulfill your order. Please wait...',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.description.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                          onPressed: () async {
                            final Uri launchUri = Uri(
                              scheme: 'tel',
                              path: order.shopPhone,
                            );
                            if (await canLaunchUrl(launchUri)) {
                              await launchUrl(launchUri);
                            }
                          },
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
                              onPressed: () async {
                                final Uri launchUri = Uri(
                                  scheme: 'tel',
                                  path: order.riderPhone,
                                );
                                if (await canLaunchUrl(launchUri)) {
                                  await launchUrl(launchUri);
                                }
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
                    if (isCancelled)
                      _buildStatusRow(
                        'Cancelled',
                        true,
                        false,
                      )
                    else ...[
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
                  ],
                ),
              ),

              // --- 3.5 Quote Approval (If Applicable) ---
              if ((order.orderStatus == 'pending' ||
                      order.orderStatus == 'bidding' ||
                      order.orderStatus == 'searching_for_pharmacy' ||
                      order.orderStatus == 'awaiting_customer_approval' ||
                      order.orderStatus == 'pending_payment' ||
                      order.orderStatus == 'checkout_pending') &&
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

              // --- AdMob Native Ad ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: NativeAdWidget(templateType: TemplateType.medium),
              ),

              // --- Cancel Order Button ---
              if (order.orderStatus == 'pending' ||
                  order.orderStatus == 'bidding' ||
                  order.orderStatus == 'searching_for_pharmacy' ||
                  order.orderStatus == 'awaiting_customer_approval')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cancel Order'),
                            content: const Text('Are you sure you want to cancel this order?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && order.orderId != null) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          );
                          await ref.read(orderProvider.notifier).cancelOrder(order.orderId!);
                          if (mounted) {
                            Navigator.pop(context); // Pop loading dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Order Cancelled Successfully')),
                            );
                            context.pop(); // Go back
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withAlpha(25),
                        foregroundColor: AppColors.error,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.error, width: 1.5),
                        ),
                      ),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel Order', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),

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
                        onPressed: () => context.go('/lab-tests'),
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
