import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:io';

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

  OrderNotifier(this.ref, this._orderService) : super(OrderState()) {
    // Optionally fetch orders on init if user is logged in
    Future.microtask(() {
      if (_customerId != null) {
        fetchOrders(refresh: true);
      }
    });
  }

  String? get _customerId => ref.read(profileProvider).user?.customerId;

  Future<void> fetchOrders({bool refresh = false}) async {
    final cid = _customerId;
    if (cid == null) return;

    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
        hasMore: true,
        orders: [],
      );
    } else {
      if (!state.hasMore || state.isLoading) return;
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final response = await _orderService.getCustomerOrders(
        customerId: cid,
        page: state.currentPage,
        limit: 10,
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? [];
        final parsedOrders = data.map((e) => OrderModel.fromMap(e)).toList();

        final total = response.data['total'] ?? 0;
        final newOrders = refresh
            ? parsedOrders
            : [...state.orders, ...parsedOrders];
        final hasMore = newOrders.length < total;

        state = state.copyWith(
          orders: newOrders,
          isLoading: false,
          currentPage: state.currentPage + 1,
          hasMore: hasMore,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to fetch orders',
        );
      }
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

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _orderService.placeOrderFromCart(
        customerId: cid,
        platformFee: platformFee,
        deliveryFee: deliveryFee,
        taxes: taxes,
        paymentMode: paymentMode,
        receiverName: receiverName,
        receiverPhone: receiverPhone,
        deliveryAddress: deliveryAddress,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newOrder = OrderModel.fromMap(response.data['order']);

        // Refresh orders list and cart
        ref.read(cartProvider.notifier).clearCartLocal();
        await fetchOrders(refresh: true);

        state = state.copyWith(isLoading: false);
        return newOrder;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
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
      final response = await _orderService.placeOrderFromPrescription(
        customerId: cid,
        prescriptionFile: prescriptionFile,
        receiverName: receiverName,
        receiverPhone: receiverPhone,
        deliveryAddress: deliveryAddress,
        platformFee: platformFee,
        deliveryFee: deliveryFee,
        taxes: taxes,
        paymentMode: paymentMode,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newOrder = OrderModel.fromMap(response.data['order']);
        await fetchOrders(refresh: true);
        state = state.copyWith(isLoading: false);
        return newOrder;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
    return null;
  }

  Future<void> cancelOrder(String orderId) async {
    final cid = _customerId;
    if (cid == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _orderService.cancelOrder(
        customerId: cid,
        orderId: orderId,
      );

      if (response.statusCode == 200) {
        // Update the order locally
        final updatedOrder = OrderModel.fromMap(response.data['order']);
        final updatedOrders = state.orders
            .map((o) => o.orderId == orderId ? updatedOrder : o)
            .toList();
        state = state.copyWith(orders: updatedOrders, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> initiateOnlinePayment(String orderId) async {
    final cid = _customerId;
    if (cid == null) return null;

    try {
      final response = await _orderService.initiateOnlinePayment(
        customerId: cid,
        orderId: orderId,
      );

      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<bool> verifyOnlinePayment({
    required String orderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    final cid = _customerId;
    if (cid == null) return false;

    try {
      final response = await _orderService.verifyOnlinePayment(
        customerId: cid,
        orderId: orderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        razorpaySignature: razorpaySignature,
      );

      if (response.statusCode == 200) {
        final updatedOrder = OrderModel.fromMap(response.data['order']);
        final updatedOrders = state.orders
            .map((o) => o.orderId == orderId ? updatedOrder : o)
            .toList();
        state = state.copyWith(orders: updatedOrders);
        return true;
      }
    } catch (e) {
      rethrow;
    }
    return false;
  }
}
