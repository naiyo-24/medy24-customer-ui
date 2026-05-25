import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/order.dart';
import '../providers/profile_provider.dart';
import '../providers/cart_provider.dart';
import '../services/order_services.dart';

class OrderState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  OrderState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final Ref ref;
  final OrderService _orderService;
  StreamSubscription? _wsSubscription;

  // Completers to simulate request/response over WebSocket
  Completer<OrderModel?>? _placeOrderCompleter;
  Completer<Map<String, dynamic>?>? _paymentInitiateCompleter;
  Completer<bool>? _paymentVerifyCompleter;
  Completer<void>? _cancelCompleter;

  OrderNotifier(this.ref, this._orderService) : super(OrderState()) {
    _wsSubscription = _orderService.messageStream.listen(_handleWebSocketMessage);
    
    // Connect initially if customer is logged in
    Future.microtask(() {
      final cid = _customerId;
      if (cid != null) {
        _orderService.connect(cid);
        fetchOrders(refresh: true);
      }
    });
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
      final errorMsg = data['message'] ?? 'An error occurred';
      state = state.copyWith(isLoading: false, error: errorMsg);
      _rejectAllCompleters();
      return;
    }

    switch (type) {
      case 'orders_list':
        final List ordersData = data['data'] ?? [];
        final parsedOrders = ordersData.map((e) => OrderModel.fromMap(e)).toList();
        final total = data['total'] ?? 0;
        final page = data['page'] ?? 1;
        
        final newOrders = (page == 1) 
            ? parsedOrders 
            : [...state.orders, ...parsedOrders];
            
        state = state.copyWith(
          orders: newOrders,
          isLoading: false,
          currentPage: page + 1,
          hasMore: newOrders.length < total,
        );
        break;

      case 'order_details':
        final updatedOrder = OrderModel.fromMap(data['order']);
        _updateSingleOrderInState(updatedOrder);
        break;

      case 'order_placed':
        final newOrder = OrderModel.fromMap(data['order']);
        _updateSingleOrderInState(newOrder);
        fetchOrders(refresh: true); // fetch fresh list 
        
        if (newOrder.orderType == 'cart') {
          ref.read(cartProvider.notifier).clearCartLocal();
        }

        state = state.copyWith(isLoading: false);
        _placeOrderCompleter?.complete(newOrder);
        _placeOrderCompleter = null;
        break;

      case 'order_accepted':
      case 'order_status_update':
      case 'order_updated':
        final updatedOrder = OrderModel.fromMap(data['order']);
        _updateSingleOrderInState(updatedOrder);
        break;

      case 'order_cancelled':
        final cancelledOrder = OrderModel.fromMap(data['order']);
        _updateSingleOrderInState(cancelledOrder);
        state = state.copyWith(isLoading: false);
        _cancelCompleter?.complete();
        _cancelCompleter = null;
        break;

      case 'payment_initiated':
        _paymentInitiateCompleter?.complete({
          'razorpay_order_id': data['razorpay_order_id'],
          'amount': data['amount'],
          'currency': data['currency'],
        });
        _paymentInitiateCompleter = null;
        break;

      case 'payment_verified':
        final verifiedOrder = OrderModel.fromMap(data['order']);
        _updateSingleOrderInState(verifiedOrder);
        _paymentVerifyCompleter?.complete(true);
        _paymentVerifyCompleter = null;
        break;
        
      case 'pong':
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

  void _rejectAllCompleters() {
    if (_placeOrderCompleter?.isCompleted == false) _placeOrderCompleter?.complete(null);
    if (_paymentInitiateCompleter?.isCompleted == false) _paymentInitiateCompleter?.complete(null);
    if (_paymentVerifyCompleter?.isCompleted == false) _paymentVerifyCompleter?.complete(false);
    if (_cancelCompleter?.isCompleted == false) _cancelCompleter?.complete(); // Just complete it normally
    
    _placeOrderCompleter = null;
    _paymentInitiateCompleter = null;
    _paymentVerifyCompleter = null;
    _cancelCompleter = null;
  }

  void _ensureConnection() {
    final cid = _customerId;
    if (cid != null && !_orderService.isConnected) {
      _orderService.connect(cid);
    }
  }

  Future<void> fetchOrders({bool refresh = false}) async {
    final cid = _customerId;
    if (cid == null) return;

    _ensureConnection();

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
      _orderService.sendMessage({
        "type": "get_orders",
        "page": state.currentPage,
        "limit": 10
      });
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<OrderModel?> placeOrderFromCart({
    required double platformFee,
    required double deliveryFee,
    required double taxes,
    required String paymentMode,
    required String receiverName,
    required String receiverPhone,
    required Map<String, dynamic> deliveryAddress,
  }) async {
    final cid = _customerId;
    if (cid == null) return null;

    _ensureConnection();

    state = state.copyWith(isLoading: true, error: null);
    _placeOrderCompleter = Completer<OrderModel?>();
    final future = _placeOrderCompleter!.future;

    try {
      _orderService.sendMessage({
        "type": "place_order_from_cart",
        "platform_fee": platformFee,
        "delivery_fee": deliveryFee,
        "taxes": taxes,
        "payment_mode": paymentMode,
        "receiver_name": receiverName,
        "receiver_phone": receiverPhone,
        "delivery_address": deliveryAddress,
      });
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      _rejectAllCompleters();
    }

    return future;
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

    _ensureConnection();

    state = state.copyWith(isLoading: true, error: null);
    _placeOrderCompleter = Completer<OrderModel?>();
    final future = _placeOrderCompleter!.future;

    final bytes = await prescriptionFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    try {
      _orderService.sendMessage({
        "type": "place_order_from_prescription",
        "platform_fee": platformFee,
        "delivery_fee": deliveryFee,
        "taxes": taxes,
        "payment_mode": paymentMode,
        "receiver_name": receiverName,
        "receiver_phone": receiverPhone,
        "delivery_address": deliveryAddress,
        "prescription": base64Image,
      });
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      _rejectAllCompleters();
    }

    return future;
  }

  Future<void> cancelOrder(String orderId) async {
    final cid = _customerId;
    if (cid == null) return;

    _ensureConnection();

    state = state.copyWith(isLoading: true, error: null);
    _cancelCompleter = Completer<void>();
    final future = _cancelCompleter!.future;

    try {
      _orderService.sendMessage({
        "type": "cancel_order",
        "order_id": orderId
      });
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      _rejectAllCompleters();
    }

    return future;
  }

  Future<Map<String, dynamic>?> initiateOnlinePayment(String orderId) async {
    final cid = _customerId;
    if (cid == null) return null;

    _ensureConnection();

    _paymentInitiateCompleter = Completer<Map<String, dynamic>?>();
    final future = _paymentInitiateCompleter!.future;

    try {
      _orderService.sendMessage({
        "type": "initiate_payment",
        "order_id": orderId
      });
    } catch (e) {
      _rejectAllCompleters();
    }

    return future;
  }

  Future<bool> verifyOnlinePayment({
    required String orderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    final cid = _customerId;
    if (cid == null) return false;

    _ensureConnection();

    _paymentVerifyCompleter = Completer<bool>();
    final future = _paymentVerifyCompleter!.future;

    try {
      _orderService.sendMessage({
        "type": "verify_payment",
        "order_id": orderId,
        "razorpay_payment_id": razorpayPaymentId,
        "razorpay_order_id": razorpayOrderId,
        "razorpay_signature": razorpaySignature,
      });
    } catch (e) {
      _rejectAllCompleters();
    }

    return future;
  }
}
