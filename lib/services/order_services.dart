import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_url.dart';

class OrderService {
  WebSocketChannel? _biddingChannel;
  WebSocketChannel? _trackingChannel;
  final Dio _dio = Dio();
  
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  OrderService() {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  // GraphQL query to get order history
  static const String _getOrderHistoryQuery = """
    query GetMyOrderHistory(\$customerId: String!, \$limit: Int!) {
      getMyOrderHistory(customerId: \$customerId, limit: \$limit) {
        order_id: orderId
        customer_id: customerId
        shop_id: shopId
        order_type: orderType
        prescription_url: prescriptionUrl
        items
        receiver_name: receiverName
        receiver_phone: receiverPhone
        delivery_address: deliveryAddress
        item_total: itemTotal
        platform_fee: platformFee
        delivery_fee: deliveryFee
        taxes
        total_bill_amount: totalBillAmount
        payment_mode: paymentMode
        payment_status: paymentStatus
        order_status: orderStatus
        rider_name: riderName
        rider_phone: riderPhone
        vehicle_number: vehicleNumber
        vehicle_model: vehicleModel
        delivery_otp: dropOtp
        transaction_id: transactionId
        accepted_at: acceptedAt
        delivered_at: deliveredAt
        created_at: createdAt
      }
    }
  """;

  Future<Response> fetchOrderHistory(String customerId, int limit) async {
    return await _dio.post(
      ApiUrl.graphql,
      data: {
        'query': _getOrderHistoryQuery,
        'variables': {
          'customerId': customerId,
          'limit': limit,
        }
      },
    );
  }

  Future<Response> placeOrder(Map<String, dynamic> payload) async {
    return await _dio.post(
      ApiUrl.placeOrder,
      data: payload,
    );
  }

  Future<Response> acceptBid(String orderId, String bidId) async {
    return await _dio.post(
      ApiUrl.acceptBid(orderId),
      data: {'bid_id': bidId},
    );
  }

  void connectBidding(String orderId) {
    disconnectBidding();
    final url = ApiUrl.biddingWebSocket(orderId);
    try {
      _biddingChannel = WebSocketChannel.connect(Uri.parse(url));
      _biddingChannel!.stream.listen(
        (data) {
          try {
            final decoded = json.decode(data as String) as Map<String, dynamic>;
            _messageController.add(decoded);
          } catch (e) {
            if (kDebugMode) print("Bidding WS parse error: $e");
          }
        },
        onDone: () => _biddingChannel = null,
        onError: (e) {
          if (kDebugMode) print("Bidding WS error: $e");
          _biddingChannel = null;
        },
      );
    } catch (e) {
      if (kDebugMode) print("Failed to initiate Bidding WS: $e");
    }
  }

  void disconnectBidding() {
    _biddingChannel?.sink.close();
    _biddingChannel = null;
  }

  void connectTracking(String orderId) {
    disconnectTracking();
    final url = ApiUrl.trackingWebSocket(orderId);
    try {
      _trackingChannel = WebSocketChannel.connect(Uri.parse(url));
      _trackingChannel!.stream.listen(
        (data) {
          try {
            final decoded = json.decode(data as String) as Map<String, dynamic>;
            _messageController.add(decoded);
          } catch (e) {
            if (kDebugMode) print("Tracking WS parse error: $e");
          }
        },
        onDone: () => _trackingChannel = null,
        onError: (e) {
          if (kDebugMode) print("Tracking WS error: $e");
          _trackingChannel = null;
        },
      );
    } catch (e) {
      if (kDebugMode) print("Failed to initiate Tracking WS: $e");
    }
  }

  void disconnectTracking() {
    _trackingChannel?.sink.close();
    _trackingChannel = null;
  }

  void dispose() {
    disconnectBidding();
    disconnectTracking();
    _messageController.close();
  }
}
