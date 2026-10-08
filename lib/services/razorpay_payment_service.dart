import 'package:customer_app/services/api_url.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPaymentService {

  Razorpay? _razorpay;
  bool _handlersRegistered = false;

  /// Verifies the native Razorpay plugin is registered.
  static Future<bool> isPluginAvailable() async {
    // We bypass the resync check because the Razorpay plugin doesn't support it
    // and throws MissingPluginException which prevents the payment sheet from loading.
    return true;
  }

  /// Registers listeners once the native plugin is available.
  Future<bool> ensureReady({
    required void Function(PaymentSuccessResponse response) onSuccess,
    required void Function(PaymentFailureResponse response) onError,
    void Function(ExternalWalletResponse response)? onExternalWallet,
  }) async {
    if (_handlersRegistered && _razorpay != null) return true;

    final available = await isPluginAvailable();
    if (!available) return false;

    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    if (onExternalWallet != null) {
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
    }
    _handlersRegistered = true;
    return true;
  }

  Future<void> openCheckout({
    required String orderId,
    required int amountPaise,
    required String contact,
    required String description,
    String? email,
    String? name,
  }) async {
    if (_razorpay == null) {
      throw StateError('Razorpay is not initialized. Call ensureReady() first.');
    }

    final options = {
      'key': ApiUrl.razorpayKeyId,
      'amount': amountPaise,
      'order_id': orderId,
      'name': name ?? 'MedApp',
      'description': description,
      'currency': 'INR',
      'prefill': {
        'contact': contact,
        if (email != null && email.isNotEmpty) 'email': email,
      },
    };
    _razorpay!.open(options);
  }

  Future<Response> createOrder(String receiptId, double amount) async {
    final dio = Dio();
    dio.interceptors.add(PrettyDioLogger(requestHeader: true, requestBody: true, responseBody: true, error: true, compact: true));
    return await dio.post(
      ApiUrl.razorpayCreateOrder,
      data: {
        'internal_receipt_id': receiptId,
        'amount': amount,
      },
    );
  }

  Future<Response> verifyPayment(String razorpayOrderId, String razorpayPaymentId, String razorpaySignature) async {
    final dio = Dio();
    dio.interceptors.add(PrettyDioLogger(requestHeader: true, requestBody: true, responseBody: true, error: true, compact: true));
    return await dio.post(
      ApiUrl.razorpayVerify,
      data: {
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      },
    );
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
    _handlersRegistered = false;
  }
}
