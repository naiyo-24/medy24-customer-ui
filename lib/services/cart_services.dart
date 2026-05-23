import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_url.dart';

class CartService {
  final Dio _dio = Dio();

  CartService() {
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

  Future<Response> addItem(String customerId, String medicineId, int quantity) async {
    try {
      return await _dio.post(
        ApiUrl.cartAddItem,
        data: {
          'medicine_id': medicineId,
          'quantity': quantity,
        },
        options: _getOptions(customerId),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateItem(String customerId, String medicineId, int quantity) async {
    try {
      return await _dio.put(
        ApiUrl.cartUpdateItem(medicineId),
        data: quantity,
        options: _getOptions(customerId),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> removeItem(String customerId, String medicineId) async {
    try {
      return await _dio.delete(
        ApiUrl.cartRemoveItem(medicineId),
        options: _getOptions(customerId),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getCart(String customerId) async {
    try {
      return await _dio.get(
        ApiUrl.cartGet,
        options: _getOptions(customerId),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> clearCart(String customerId) async {
    try {
      return await _dio.delete(
        ApiUrl.cartClear,
        options: _getOptions(customerId),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getSummary(String customerId) async {
    try {
      return await _dio.get(
        ApiUrl.cartSummary,
        options: _getOptions(customerId),
      );
    } catch (e) {
      rethrow;
    }
  }
}
