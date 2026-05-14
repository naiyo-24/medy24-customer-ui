import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_url.dart';

class LabTestService {
  final Dio _dio = Dio();

  LabTestService() {
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

  Future<Response> getAllTests({int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiUrl.getLabTestAll,
        queryParameters: {'page': page, 'limit': limit},
      );
      return response;
    } on DioException catch (e) {
      throw e.message ?? "An error occurred while fetching tests";
    }
  }

  Future<Response> getTestById(String testId) async {
    try {
      final response = await _dio.get(ApiUrl.getLabTestById(testId));
      return response;
    } on DioException catch (e) {
      throw e.message ?? "An error occurred while fetching test details";
    }
  }

  Future<Response> getTestsByLabId(String labId, {int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiUrl.getLabTestsByLabId(labId),
        queryParameters: {'page': page, 'limit': limit},
      );
      return response;
    } on DioException catch (e) {
      throw e.message ?? "An error occurred while fetching lab's tests";
    }
  }

  // Test Package Methods
  Future<Response> getPackageById(String packageId) async {
    try {
      final response = await _dio.get(ApiUrl.getTestPackageById(packageId));
      return response;
    } on DioException catch (e) {
      throw e.message ?? "An error occurred while fetching package details";
    }
  }

  Future<Response> getPackagesByLabId(String labId, {int page = 1, int limit = 20}) async {
    try {
      final response = await _dio.get(
        ApiUrl.getTestPackagesByLabId(labId),
        queryParameters: {'page': page, 'limit': limit},
      );
      return response;
    } on DioException catch (e) {
      throw e.message ?? "An error occurred while fetching lab's packages";
    }
  }
}
