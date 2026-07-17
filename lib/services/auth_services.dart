import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_url.dart';

class AuthService {
  final Dio _dio = Dio();

  AuthService() {
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

  Future<Response> checkPhone(String phoneNumber) async {
    try {
      return await _dio.post(
        ApiUrl.checkPhone,
        data: {'phone': phoneNumber},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> sendOtp(String phoneNumber) async {
    try {
      return await _dio.post(
        ApiUrl.sendOtp,
        data: {'phone_number': phoneNumber},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> verifyOtp({
    required String token,
    required String phoneNumber,
    String? fullName,
    String? email,
    String? alternativePhoneNo,
    List<dynamic>? savedAddresses,
    File? profilePhoto,
  }) async {
    try {
      // The new backend endpoint only expects the Firebase token in the Authorization header
      return await _dio.post(
        ApiUrl.customerLogin,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getProfile(String customerId) async {
    try {
      return await _dio.get(ApiUrl.getProfile(customerId));
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProfile({
    required String customerId,
    String? fullName,
    String? email,
    String? alternativePhoneNo,
    String? status,
    File? profilePhoto,
  }) async {
    try {
      final formDataMap = <String, dynamic>{};
      if (fullName != null) formDataMap['full_name'] = fullName;
      if (email != null) formDataMap['email'] = email;
      if (alternativePhoneNo != null) {
        formDataMap['alternative_phone_no'] = alternativePhoneNo;
      }
      if (status != null) formDataMap['status'] = status;
      if (profilePhoto != null) {
        formDataMap['profile_photo'] = await MultipartFile.fromFile(
          profilePhoto.path,
          filename: profilePhoto.path.split('/').last,
        );
      }

      final formData = FormData.fromMap(formDataMap);
      return await _dio.put(ApiUrl.updateProfile(customerId), data: formData);
    } catch (e) {
      rethrow;
    }
  }

  static const String _addAddressMutation = """
    mutation AddSavedAddress(\$customerId: String!, \$addressType: String!, \$address1: String!, \$streetAddress: String!, \$latitude: Float!, \$longitude: Float!) {
      addSavedAddress(
        customerId: \$customerId,
        addressType: \$addressType,
        address1: \$address1,
        streetAddress: \$streetAddress,
        latitude: \$latitude,
        longitude: \$longitude
      )
    }
  """;

  static const String _deleteAddressMutation = """
    mutation DeleteSavedAddress(\$customerId: String!, \$addressId: String!) {
      deleteSavedAddress(
        customerId: \$customerId,
        addressId: \$addressId
      )
    }
  """;

  Future<Response> addAddress({
    required String customerId,
    required String address1,
    required String streetAddress,
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await _dio.post(
        ApiUrl.graphql,
        data: {
          'query': _addAddressMutation,
          'variables': {
            'customerId': customerId,
            'addressType': 'Home',
            'address1': address1,
            'streetAddress': streetAddress,
            'latitude': latitude,
            'longitude': longitude,
          }
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteAddress({
    required String customerId,
    required String addressId,
    required String token,
  }) async {
    try {
      return await _dio.post(
        ApiUrl.graphql,
        data: {
          'query': _deleteAddressMutation,
          'variables': {
            'customerId': customerId,
            'addressId': addressId,
          }
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      rethrow;
    }
  }
}
