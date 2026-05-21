import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/charges.dart';
import 'api_url.dart';

class ChargesService {
  final Dio _dio = Dio();

  ChargesService() {
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

  Future<List<ChargesModel>> fetchPlatformFees() async {
    try {
      final response = await _dio.get(ApiUrl.platformFee);
      return _parseChargesList(response.data);
    } on DioException catch (e) {
      throw e.response?.data?['message'] ??
          e.message ??
          'Failed to fetch platform fees';
    }
  }

  List<ChargesModel> _parseChargesList(dynamic data) {
    if (data is List) {
      return data
          .map((item) => ChargesModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (data is Map<String, dynamic>) {
      final nested = data['data'] ?? data['charges'] ?? data['list'];
      if (nested is List) {
        return nested
            .map((item) => ChargesModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }
}
