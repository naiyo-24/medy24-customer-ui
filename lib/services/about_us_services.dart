import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_url.dart';

class AboutUsServices {
  final Dio _dio = Dio();

  AboutUsServices() {
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

  Future<Response> getAllAboutUs() async {
    return await _dio.get(ApiUrl.getAboutUsAll);
  }

  Future<Response> getAboutUsById(int id) async {
    return await _dio.get(ApiUrl.getAboutUsById(id));
  }
}
