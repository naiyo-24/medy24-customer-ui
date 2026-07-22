import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/order.dart';
import '../providers/profile_provider.dart';
import '../providers/cart_provider.dart';
import '../services/order_services.dart';
import '../models/cart.dart';

class OrderState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? activeBiddingOrderId;
  final String? activeTrackingOrderId;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.activeBiddingOrderId,
    this.activeTrackingOrderId,
  });

  OrderState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? activeBiddingOrderId,
    String? activeTrackingOrderId,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      activeBiddingOrderId: activeBiddingOrderId ?? this.activeBiddingOrderId,
      activeTrackingOrderId: activeTrackingOrderId ?? this.activeTrackingOrderId,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final Ref ref;
  final OrderService _orderService;

  OrderService get orderService => _orderService;

  StreamSubscription? _wsSubscription;

  OrderNotifier(this.ref, this._orderService) : super(OrderState()) {
    _wsSubscription = _orderService.messageStream.listen(
      _handleWebSocketMessage,
    );

    // Fetch initially if customer is logged in
    Future.microtask(() {
      final cid = _customerId;
      if (cid != null) {
        fetchOrders(refresh: true);
      }
    });
  }

  void reset() {
    state = OrderState();
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }

  String? get _customerId => ref.read(profileProvider).user?.customerId;

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    final type = data['type'];

    if (data['status'] == 'error' || type == 'error') {
      final errorMsg = data['message'] ?? 'An error occurred in live tracking';
      if (kDebugMode) print("WebSocket Message Error: $errorMsg");
      return;
    }

    switch (type) {
      case 'REHYDRATE_BIDS':
        final List bidsData = data['bids'] ?? [];
        if (state.activeBiddingOrderId != null) {
          final orderId = state.activeBiddingOrderId!;
          final index = state.orders.indexWhere((o) => o.orderId == orderId);
          if (index >= 0) {
            final order = state.orders[index];
            final newQuotes = bidsData.map((e) => QuoteModel.fromMap(e)).toList();
            final updatedOrder = OrderModel(
              orderId: order.orderId,
              customerId: order.customerId,
              shopId: order.shopId,
              shopName: order.shopName,
              shopPhone: order.shopPhone,
              orderType: order.orderType,
              prescriptionUrl: order.prescriptionUrl,
              items: order.items,
              quotes: newQuotes,
              receiverName: order.receiverName,
              receiverPhone: order.receiverPhone,
              deliveryAddress: order.deliveryAddress,
              itemTotal: order.itemTotal,
              platformFee: order.platformFee,
              deliveryFee: order.deliveryFee,
              taxes: order.taxes,
              totalBillAmount: order.totalBillAmount,
              paymentMode: order.paymentMode,
              paymentStatus: order.paymentStatus,
              orderStatus: newQuotes.isNotEmpty ? 'awaiting_customer_approval' : order.orderStatus,
              riderName: order.riderName,
              riderPhone: order.riderPhone,
              vehicleNumber: order.vehicleNumber,
              vehicleModel: order.vehicleModel,
              deliveryOtp: order.deliveryOtp,
              transactionId: order.transactionId,
              acceptedAt: order.acceptedAt,
              deliveredAt: order.deliveredAt,
              createdAt: order.createdAt,
            );
            _updateSingleOrderInState(updatedOrder);
          }
        }
        break;

      case 'NEW_BID':
        final bidData = data['data'];
        final orderId = bidData['order_id'];
        
        final index = state.orders.indexWhere((o) => o.orderId == orderId);
        if (index >= 0) {
          final order = state.orders[index];
          final newQuote = QuoteModel.fromMap(bidData);
          
          final existingQuoteIndex = order.quotes.indexWhere(
            (q) => q.shopId == newQuote.shopId,
          );
          
          List<QuoteModel> updatedQuotes;
          if (existingQuoteIndex >= 0) {
            updatedQuotes = List<QuoteModel>.from(order.quotes);
            updatedQuotes[existingQuoteIndex] = newQuote;
          } else {
            updatedQuotes = List<QuoteModel>.from(order.quotes)..add(newQuote);
          }
          
          final updatedOrder = OrderModel(
            orderId: order.orderId,
            customerId: order.customerId,
            shopId: order.shopId,
            shopName: order.shopName,
            shopPhone: order.shopPhone,
            orderType: order.orderType,
            prescriptionUrl: order.prescriptionUrl,
            items: order.items,
            quotes: updatedQuotes,
            receiverName: order.receiverName,
            receiverPhone: order.receiverPhone,
            deliveryAddress: order.deliveryAddress,
            itemTotal: order.itemTotal,
            platformFee: order.platformFee,
            deliveryFee: order.deliveryFee,
            taxes: order.taxes,
            totalBillAmount: order.totalBillAmount,
            paymentMode: order.paymentMode,
            paymentStatus: order.paymentStatus,
            orderStatus: 'awaiting_customer_approval',
            riderName: order.riderName,
            riderPhone: order.riderPhone,
            vehicleNumber: order.vehicleNumber,
            vehicleModel: order.vehicleModel,
            deliveryOtp: order.deliveryOtp,
            transactionId: order.transactionId,
            acceptedAt: order.acceptedAt,
            deliveredAt: order.deliveredAt,
            createdAt: order.createdAt,
          );
          _updateSingleOrderInState(updatedOrder);
        }
        break;

      case 'AUCTION_CLOSED':
        // The backend indicates auction closed. 
        _orderService.disconnectBidding();
        state = state.copyWith(activeBiddingOrderId: null);
        break;
        
      case 'RIDER_LOCATION_UPDATE':
        // Handle rider tracking logic here
        break;
    }
  }

  void _updateSingleOrderInState(OrderModel order) {
    final index = state.orders.indexWhere((o) => o.orderId == order.orderId);
    if (index >= 0) {
      final updatedOrders = List<OrderModel>.from(state.orders);
      updatedOrders[index] = order;
      state = state.copyWith(orders: updatedOrders);
    } else {
      state = state.copyWith(orders: [order, ...state.orders]);
    }
  }

  Future<void> fetchOrders({bool refresh = false}) async {
    final cid = _customerId;
    if (cid == null) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
        hasMore: true,
      );
    } else {
      if (!state.hasMore || state.isLoading) return;
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _orderService.fetchOrderHistory(cid, 20);
      final data = response.data;
      if (data['errors'] != null) {
         throw Exception(data['errors'][0]['message']);
      }
      
      final ordersList = data['data']['getMyOrderHistory'] as List;
      final parsedOrders = ordersList.map((e) => OrderModel.fromMap(e)).toList();
      
      final newOrders = refresh
          ? parsedOrders
          : [...state.orders, ...parsedOrders];

      state = state.copyWith(
        orders: newOrders,
        isLoading: false,
        currentPage: state.currentPage + 1,
        hasMore: parsedOrders.isNotEmpty,
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<OrderModel?> placeOrderFromCart({
    required List<CartItem> cartItems,
    required double itemTotal,
    required double totalBillAmount,
    required double platformFee,
    required double deliveryFee,
    required double taxes,
    required double deliveryTip,
    required String paymentMode,
    required String receiverName,
    required String receiverPhone,
    required Map<String, dynamic> deliveryAddress,
  }) async {
    final cid = _customerId;
    if (cid == null) return null;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final String addressText = deliveryAddress['address'] ?? "${deliveryAddress['addressLine1']}, ${deliveryAddress['addressLine2']}, ${deliveryAddress['city']}, ${deliveryAddress['state']}, ${deliveryAddress['pincode']}";
      
      final payload = {
        "customer_id": cid,
        "receiver_name": receiverName,
        "receiver_phone": receiverPhone,
        "delivery_address_text": addressText,
        "delivery_lat": deliveryAddress['lat'] ?? deliveryAddress['latitude'] ?? 0.0,
        "delivery_lng": deliveryAddress['lng'] ?? deliveryAddress['longitude'] ?? 0.0,
        "is_emergency": false,
        "instructions": "",
        "items": cartItems.map((e) => e.toMap()).toList(),
        "item_total": itemTotal,
        "platform_fee": platformFee,
        "delivery_fee": deliveryFee,
        "taxes": taxes,
        "total_bill_amount": totalBillAmount,
        "payment_mode": paymentMode,
        "order_type": "cart",
      };
      
      final response = await _orderService.placeOrder(payload);
      
      if (response.data['status'] == 'success') {
        final orderId = response.data['order_id'];
        
        _orderService.connectBidding(orderId);
        await fetchOrders(refresh: true);
        state = state.copyWith(isLoading: false, activeBiddingOrderId: orderId);
        
        final index = state.orders.indexWhere((o) => o.orderId == orderId);
        if (index >= 0) {
          // Clear cart on success
          ref.read(cartProvider.notifier).clearCartLocal();
          return state.orders[index];
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }

    return null;
  }

  Future<OrderModel?> approveQuote(
    String orderId,
    String quoteId,
    String paymentMode,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _orderService.acceptBid(orderId, quoteId);
      
      if (response.data['status'] == 'success') {
        await fetchOrders(refresh: true);
        state = state.copyWith(isLoading: false);
        
        if (state.activeBiddingOrderId == orderId) {
           _orderService.disconnectBidding();
           state = state.copyWith(activeBiddingOrderId: null);
        }
        
        final index = state.orders.indexWhere((o) => o.orderId == orderId);
        if (index >= 0) return state.orders[index];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to accept bid');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
    
    return null;
  }

  Future<OrderModel?> rejectQuote(String orderId, String quoteId) async {
    if (kDebugMode) print("rejectQuote not yet implemented on backend");
    return null;
  }

  Future<OrderModel?> placeOrderFromPrescription({
    required File prescriptionFile,
    required String receiverName,
    required String receiverPhone,
    required Map<String, dynamic> deliveryAddress,
    required double platformFee,
    required double deliveryFee,
    required double taxes,
    required String paymentMode,
  }) async {
    final cid = _customerId;
    if (cid == null) return null;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1. Upload the prescription
      final uploadResponse = await _orderService.uploadPrescription(cid, prescriptionFile);
      if (uploadResponse.data['status'] != 'success') {
         throw Exception(uploadResponse.data['detail'] ?? 'Failed to upload prescription');
      }
      final prescriptionUrl = uploadResponse.data['prescription_url'];

      // 2. Place the order
      final String addressText = deliveryAddress['address'] ?? "${deliveryAddress['addressLine1']}, ${deliveryAddress['addressLine2']}, ${deliveryAddress['city']}, ${deliveryAddress['state']}, ${deliveryAddress['pincode']}";
      
      final payload = {
        "customer_id": cid,
        "receiver_name": receiverName,
        "receiver_phone": receiverPhone,
        "delivery_address_text": addressText,
        "delivery_lat": deliveryAddress['lat'] ?? deliveryAddress['latitude'] ?? 0.0,
        "delivery_lng": deliveryAddress['lng'] ?? deliveryAddress['longitude'] ?? 0.0,
        "is_emergency": false,
        "instructions": "",
        "order_type": "prescription",
        "prescription_url": prescriptionUrl,
        "payment_mode": paymentMode,
      };
      
      final response = await _orderService.placeOrder(payload);
      
      if (response.data['status'] == 'success') {
        final orderId = response.data['order_id'];
        
        _orderService.connectBidding(orderId);
        await fetchOrders(refresh: true);
        state = state.copyWith(isLoading: false, activeBiddingOrderId: orderId);
        
        final index = state.orders.indexWhere((o) => o.orderId == orderId);
        if (index >= 0) return state.orders[index];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }

    return null;
  }

  Future<void> cancelOrder(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _orderService.cancelOrder(orderId);
      if (response.data['status'] == 'success') {
         if (state.activeBiddingOrderId == orderId) {
             _orderService.disconnectBidding();
             state = state.copyWith(activeBiddingOrderId: null);
         }
         await fetchOrders(refresh: true);
      } else {
         throw Exception(response.data['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<Map<String, dynamic>?> initiateOnlinePayment(String orderId) async {
    state = state.copyWith(isLoading: false, error: "Online payment flow needs to be integrated with REST API");
    return null;
  }

  Future<bool> completeCheckout(String orderId, String paymentMode) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _orderService.completeCheckout(orderId, {
        'payment_mode': paymentMode,
      });

      if (response.data['status'] == 'success') {
        await fetchOrders(refresh: true);
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to complete checkout');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOnlinePayment({
    required String orderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _orderService.completeCheckout(orderId, {
        'payment_mode': 'online',
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_signature': razorpaySignature,
      });

      if (response.data['status'] == 'success') {
        await fetchOrders(refresh: true);
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Payment verification failed');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
