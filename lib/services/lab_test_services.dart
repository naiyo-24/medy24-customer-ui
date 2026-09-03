import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_url.dart';

class LabTestService {
  final Dio _dio = Dio();

  LabTestService() {
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

  static const String _searchLabTestsQuery = """
    query SearchLabTests(\$query: String!) {
      searchLabTests(query: \$query, limit: 20) {
        testId
        testName
        category
        description
        isProfile
        numberOfParameters
        sampleType
        searchTags
        fastingRequired
        fastingHours
        preTestInfo
      }
    }
  """;

  static const String _findLabsQuery = """
    query FindLabsForSelectedTests(\$testIds: [String!]!) {
      findLabsForSelectedTests(testIds: \$testIds) {
        labId
        labName
        rating
        totalPrice
        isFullMatch
        matchCount
        matchedTests {
          testId
          testName
          price
        }
        missingTests {
          testId
          testName
        }
      }
    }
  """;

  static const String _getLabTestCategoriesQuery = """
    query GetLabTestCategories(\$limit: Int!) {
      getLabTestCategories(limit: \$limit)
    }
  """;

  Future<Response> getLabTestCategories({int limit = 20}) async {
    try {
      return await _dio.post(
        ApiUrl.graphql,
        data: {
          'query': _getLabTestCategoriesQuery,
          'variables': {
            'limit': limit,
          },
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> searchLabTests(String query) async {
    try {
      return await _dio.post(
        ApiUrl.graphql,
        data: {
          'query': _searchLabTestsQuery,
          'variables': {
            'query': query,
          },
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> findLabsForSelectedTests(List<String> testIds) async {
    try {
      return await _dio.post(
        ApiUrl.graphql,
        data: {
          'query': _findLabsQuery,
          'variables': {
            'testIds': testIds,
          },
        },
      );
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Response> bookLabTests(Map<String, dynamic> payload) async {
    try {
      // POST /api/rest/lab-bookings/book?customer_id=...
      final customerId = payload['customer_id'];
      return await _dio.post(
        "${ApiUrl.baseUrl}/api/rest/lab-bookings/book",
        queryParameters: {
          'customer_id': customerId
        },
        data: payload,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getCustomerLabBookings(String customerId) async {
    try {
      return await _dio.get(
        "${ApiUrl.baseUrl}/api/rest/lab-bookings/customer/$customerId",
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getLabBookingDetails(String bookingId) async {
    try {
      return await _dio.get("${ApiUrl.baseUrl}/api/rest/lab-bookings/$bookingId");
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getLabTestsByLabId(String labId) async {
    try {
      return await _dio.get(ApiUrl.getLabTestsByLabId(labId));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getTestPackagesByLabId(String labId) async {
    try {
      return await _dio.get(ApiUrl.getTestPackagesByLabId(labId));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getLabProfile(String labId) async {
    try {
      return await _dio.get("${ApiUrl.baseUrl}/api/auth/lab/get-by/$labId");
    } catch (e) {
      rethrow;
    }
  }
}
