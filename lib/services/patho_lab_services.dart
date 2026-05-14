import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_url.dart';

class PathoLabService {
  final Dio _dio = Dio();

  PathoLabService() {
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));
  }

  Future<Response> getAllLabs({String? name, String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (name != null) queryParams['name'] = name;
      if (status != null) queryParams['status'] = status;

      final response = await _dio.get(
        ApiUrl.getPathoLabAll,
        queryParameters: queryParams,
      );
      return response;
    } on DioException catch (e) {
      throw e.message ?? "An error occurred while fetching labs";
    }
  }

  Future<Response> getLabById(String labId) async {
    try {
      final response = await _dio.get(ApiUrl.getPathoLabById(labId));
      return response;
    } on DioException catch (e) {
      throw e.message ?? "An error occurred while fetching lab details";
    }
  }
}
