import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/test_package_booking.dart';
import 'api_url.dart';

class BookTestPackageService {
  final Dio _dio = Dio();

  BookTestPackageService() {
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

  Future<Response> submitBooking(TestPackageBooking booking) async {
    final url = booking.itemType == BookingItemType.labTest
        ? ApiUrl.createLabTestBooking
        : ApiUrl.createTestPackageBooking;

    try {
      return await _dio.post(url, data: booking.toJson());
    } on DioException catch (e) {
      throw e.response?.data?['message'] ??
          e.message ??
          'Failed to submit booking';
    }
  }
}
