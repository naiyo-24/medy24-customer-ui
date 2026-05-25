import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_url.dart';

class OrderService {
  final Dio _dio = Dio();

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

  Options _getOptions(String customerId) {
    return Options(headers: {'Authorization': 'Bearer $customerId'});
  }

  Future<Response> placeOrderFromCart({
    required String customerId,
    required double platformFee,
    required double deliveryFee,
    required double taxes,
    required String paymentMode,
    required String receiverName,
    required String receiverPhone,
    required Map<String, dynamic> deliveryAddress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'platform_fee': platformFee,
        'delivery_fee': deliveryFee,
        'taxes': taxes,
        'payment_mode': paymentMode,
        'receiver_name': receiverName,
        'receiver_phone': receiverPhone,
        'delivery_address': json.encode(deliveryAddress),
      });

      return await _dio.post(
        ApiUrl.orderPlaceFromCart,
        data: formData,
        options: _getOptions(customerId),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> placeOrderFromPrescription({
    required String customerId,
    required File prescriptionFile,
    required String receiverName,
    required String receiverPhone,
    required Map<String, dynamic> deliveryAddress,
    required double platformFee,
    required double deliveryFee,
    required double taxes,
    required String paymentMode,
  }) async {
    try {
      final fileName = prescriptionFile.path.split('/').last;
      
      final formData = FormData.fromMap({
        'prescription': await MultipartFile.fromFile(
          prescriptionFile.path,
          filename: fileName,
        ),
        'receiver_name': receiverName,
        'receiver_phone': receiverPhone,
        'delivery_address': json.encode(deliveryAddress),
        'platform_fee': platformFee,
        'delivery_fee': deliveryFee,
        'taxes': taxes,
        'payment_mode': paymentMode,
      });

      return await _dio.post(
        ApiUrl.orderPlaceFromPrescription,
        data: formData,
        options: _getOptions(customerId),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getCustomerOrders({
    required String customerId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await _dio.get(
        ApiUrl.orderGetAll,
        queryParameters: {'page': page, 'limit': limit},
        options: _getOptions(customerId),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getOrderDetails({
    required String customerId,
    required String orderId,
  }) async {
    try {
      return await _dio.get(
        ApiUrl.orderGetById(orderId),
        options: _getOptions(customerId),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> cancelOrder({
    required String customerId,
    required String orderId,
  }) async {
    try {
      return await _dio.put(
        ApiUrl.orderCancel(orderId),
        options: _getOptions(customerId),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> initiateOnlinePayment({
    required String customerId,
    required String orderId,
  }) async {
    try {
      return await _dio.post(
        ApiUrl.orderInitiateOnlinePayment(orderId),
        options: _getOptions(customerId),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> verifyOnlinePayment({
    required String customerId,
    required String orderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    try {
      final formData = FormData.fromMap({
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_signature': razorpaySignature,
      });

      return await _dio.post(
        ApiUrl.orderVerifyOnlinePayment(orderId),
        data: formData,
        options: _getOptions(customerId),
      );
    } catch (e) {
      rethrow;
    }
  }
}
