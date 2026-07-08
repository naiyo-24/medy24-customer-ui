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

  static const String _getMyCartQuery = """
    query GetMyCart(\$customerId: String!) {
      getMyCart(customerId: \$customerId) {
        cartId
        customerId
        items
        totalPrice
      }
    }
  """;

  static const String _addToCartMutation = """
    mutation AddToCart(\$customerId: String!, \$medicineId: String!, \$quantity: Int!) {
      addToCart(customerId: \$customerId, medicineId: \$medicineId, quantity: \$quantity) {
        cartId
        customerId
        items
        totalPrice
      }
    }
  """;

  static const String _updateCartQuantityMutation = """
    mutation UpdateCartQuantity(\$customerId: String!, \$medicineId: String!, \$quantity: Int!) {
      updateCartQuantity(customerId: \$customerId, medicineId: \$medicineId, quantity: \$quantity) {
        cartId
        customerId
        items
        totalPrice
      }
    }
  """;

  static const String _removeFromCartMutation = """
    mutation RemoveFromCart(\$customerId: String!, \$medicineId: String!) {
      removeFromCart(customerId: \$customerId, medicineId: \$medicineId) {
        cartId
        customerId
        items
        totalPrice
      }
    }
  """;

  static const String _clearCartMutation = """
    mutation ClearCart(\$customerId: String!) {
      clearCart(customerId: \$customerId) {
        cartId
        customerId
        items
        totalPrice
      }
    }
  """;

  Future<Response> addItem(
    String customerId,
    String medicineId,
    int quantity,
  ) async {
    try {
      return await _dio.post(
        ApiUrl.graphql,
        data: {
          'query': _addToCartMutation,
          'variables': {
            'customerId': customerId,
            'medicineId': medicineId,
            'quantity': quantity,
          },
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateItem(
    String customerId,
    String medicineId,
    int quantity,
  ) async {
    try {
      return await _dio.post(
        ApiUrl.graphql,
        data: {
          'query': _updateCartQuantityMutation,
          'variables': {
            'customerId': customerId,
            'medicineId': medicineId,
            'quantity': quantity,
          },
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> removeItem(String customerId, String medicineId) async {
    try {
      return await _dio.post(
        ApiUrl.graphql,
        data: {
          'query': _removeFromCartMutation,
          'variables': {
            'customerId': customerId,
            'medicineId': medicineId,
          },
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getCart(String customerId) async {
    try {
      return await _dio.post(
        ApiUrl.graphql,
        data: {
          'query': _getMyCartQuery,
          'variables': {
            'customerId': customerId,
          },
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> clearCart(String customerId) async {
    try {
      return await _dio.post(
        ApiUrl.graphql,
        data: {
          'query': _clearCartMutation,
          'variables': {
            'customerId': customerId,
          },
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Summary is now calculated locally in the notifier, so this could be removed, 
  // but to maintain compatibility we can just return getCart
  Future<Response> getSummary(String customerId) async {
    return getCart(customerId);
  }
}
