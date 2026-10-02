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
        data: {'phone': phoneNumber},
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
      return await _dio.post(
        ApiUrl.verifyOtp,
        data: {
          'phone': phoneNumber,
          'otp': token,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> logout(String customerId, String token) async {
    try {
      return await _dio.post(
        ApiUrl.customerLogout(customerId),
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

  Future<Response> deleteCustomer(String customerId, String token) async {
    try {
      return await _dio.delete(
        ApiUrl.deleteCustomer(customerId),
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

    Future<Response> updateShopProfile(String shopId, Map<String, dynamic> data) async {
    try {
      return await _dio.put(
        '${ApiUrl.baseUrl}/api/rest/shops/$shopId/update-profile',
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> uploadShopDocuments({
    required String shopId,
    File? drugLicense,
    File? panCard,
    File? registrationCert,
  }) async {
    try {
      final formDataMap = <String, dynamic>{};
      
      if (drugLicense != null) {
        formDataMap['drug_license_upload'] = await MultipartFile.fromFile(drugLicense.path);
      }
      if (panCard != null) {
        formDataMap['pan_card_upload'] = await MultipartFile.fromFile(panCard.path);
      }
      if (registrationCert != null) {
        formDataMap['registration_certificate_upload'] = await MultipartFile.fromFile(registrationCert.path);
      }

      final formData = FormData.fromMap(formDataMap);
      return await _dio.post(
        '${ApiUrl.baseUrl}/api/rest/shops/$shopId/upload-documents',
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> retailerLogin(String phone, String password) async {
    try {
      return await _dio.post(
        '${ApiUrl.baseUrl}/api/auth/shop/login',
        data: {'phone': phone, 'password': password},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> distributorLogin(String phone, String password) async {
    try {
      return await _dio.post(
        '${ApiUrl.baseUrl}/api/v1/distributor/auth/login',
        data: {'phone': phone, 'password': password},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> registerDistributor({
    required String companyName,
    required String ownerName,
    required String phone,
    required String password,
    required String address,
    required double latitude,
    required double longitude,
    required String gstinNo,
    required String panNumber,
    String? email,
    String? bankAccountNo,
    String? bankIfscCode,
    required File license20bDoc,
    required File license21bDoc,
  }) async {
    try {
      final formDataMap = <String, dynamic>{
        'company_name': companyName,
        'owner_name': ownerName,
        'phone': phone,
        'password': password,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'gstin_no': gstinNo,
        'pan_number': panNumber,
      };

      if (email != null) formDataMap['email'] = email;
      if (bankAccountNo != null) formDataMap['bank_account_no'] = bankAccountNo;
      if (bankIfscCode != null) formDataMap['bank_ifsc_code'] = bankIfscCode;

      formDataMap['license_20b_doc'] = await MultipartFile.fromFile(
        license20bDoc.path,
        filename: license20bDoc.path.split('/').last,
      );
      formDataMap['license_21b_doc'] = await MultipartFile.fromFile(
        license21bDoc.path,
        filename: license21bDoc.path.split('/').last,
      );

      final formData = FormData.fromMap(formDataMap);
      return await _dio.post(
        '${ApiUrl.baseUrl}/api/v1/distributor/auth/register',
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> registerRetailer({
    required String phone,
    String? email,
    required String ownerName,
    required String shopName,
    required String address,
    required double latitude,
    required double longitude,
    required String licenseNumber,
    required String password,
    String? whatsappNumber,
    String? alternativePhone,
    String? gstinNo,
    String? bankAccountNo,
    String? bankIfscCode,
    String? bankName,
  }) async {
    try {
      return await _dio.post(
        '${ApiUrl.baseUrl}/api/rest/shops/register',
        data: {
          'phone': phone,
          'email': email,
          'owner_name': ownerName,
          'shop_name': shopName,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'license_number': licenseNumber,
          'shop_password': password,
          if (whatsappNumber != null && whatsappNumber.isNotEmpty) 'whatsapp_number': whatsappNumber,
          if (alternativePhone != null && alternativePhone.isNotEmpty) 'shop_alternative_phone_no': alternativePhone,
          if (gstinNo != null && gstinNo.isNotEmpty) 'gstin_no': gstinNo,
          if (bankAccountNo != null && bankAccountNo.isNotEmpty) 'bank_account_no': bankAccountNo,
          if (bankIfscCode != null && bankIfscCode.isNotEmpty) 'bank_ifsc_code': bankIfscCode,
          if (bankName != null && bankName.isNotEmpty) 'bank_name': bankName,
          'drug_license_upload': '',
          'pan_card_upload': '',
          'registration_certificate_upload': '',
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
