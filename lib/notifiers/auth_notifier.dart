import 'dart:io';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_services.dart';
import 'package:dio/dio.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isOtpSent;
  final bool isUserExists;
  final bool isInitialized;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isOtpSent = false,
    this.isUserExists = false,
    this.isInitialized = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isOtpSent,
    bool? isUserExists,
    bool? isInitialized,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isUserExists: isUserExists ?? this.isUserExists,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(AuthState(isLoading: true)) {
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        state = state.copyWith(
          user: UserModel.fromJson(userJson),
          isInitialized: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isInitialized: true, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> checkPhone(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.checkPhone(phoneNumber);
      final exists = response.data['exists'] as bool;
      state = state.copyWith(isLoading: false, isUserExists: exists);
      return exists;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Backend returns 404 when phone number doesn't exist
        state = state.copyWith(isLoading: false, isUserExists: false);
        return false;
      }
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.sendOtp(phoneNumber);
      state = state.copyWith(isLoading: false, isOtpSent: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp({
    required String token,
    required String phoneNumber,
    String? fullName,
    String? email,
    String? alternativePhoneNo,
    File? profilePhoto,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.verifyOtp(
        token: token,
        phoneNumber: phoneNumber,
        fullName: fullName,
        email: email,
        alternativePhoneNo: alternativePhoneNo,
        profilePhoto: profilePhoto,
      );

      final backendToken = response.data['access_token'];
      final customerId = response.data['user_id'];
      
      // Create a basic user model since the new endpoint only returns tokens and ID
      UserModel authenticatedUser = UserModel(
        customerId: customerId,
        phoneNumber: phoneNumber,
        fullName: fullName ?? 'Customer',
        email: email,
        alternativePhoneNo: alternativePhoneNo,
        profilePhoto: profilePhoto?.path,
        token: backendToken,
      );

      // Fetch the full profile so the Home Screen doesn't say 'Customer'
      try {
        final profileResponse = await _authService.getProfile(customerId);
        if (profileResponse.data != null) {
          final p = profileResponse.data;
          authenticatedUser = authenticatedUser.copyWith(
            fullName: p['name'] ?? authenticatedUser.fullName,
            email: p['email'] ?? authenticatedUser.email,
            profilePhoto: p['profile_picture'] ?? authenticatedUser.profilePhoto,
          );
        }
      } catch (_) {
        // Ignore profile fetch errors during login
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', authenticatedUser.toJson());

      state = state.copyWith(user: authenticatedUser, isLoading: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['detail'] ?? e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> loginRetailer(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.retailerLogin(phone, password);
      final backendToken = response.data['access_token'];
      final customerId = response.data['user_id'];
      
      UserModel authenticatedUser = UserModel(
        customerId: customerId,
        phoneNumber: phone,
        fullName: 'Retailer Shop',
        token: backendToken,
        role: 'retailer',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', authenticatedUser.toJson());

      state = state.copyWith(user: authenticatedUser, isLoading: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['detail'] ?? e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> loginDistributor(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.distributorLogin(phone, password);
      final backendToken = response.data['access_token'];
      final customerId = response.data['distributor_id'];
      
      UserModel authenticatedUser = UserModel(
        customerId: customerId,
        phoneNumber: phone,
        fullName: response.data['company_name'] ?? 'Distributor',
        token: backendToken,
        role: 'distributor',
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', authenticatedUser.toJson());

      state = state.copyWith(user: authenticatedUser, isLoading: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['detail'] ?? e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> registerDistributor({
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.registerDistributor(
        companyName: companyName,
        ownerName: ownerName,
        phone: phone,
        password: password,
        address: address,
        latitude: latitude,
        longitude: longitude,
        gstinNo: gstinNo,
        panNumber: panNumber,
        email: email,
        bankAccountNo: bankAccountNo,
        bankIfscCode: bankIfscCode,
        license20bDoc: license20bDoc,
        license21bDoc: license21bDoc,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['detail'] ?? e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> registerRetailer({
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
    File? drugLicenseFile,
    File? panCardFile,
    File? regCertFile,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.registerRetailer(
        phone: phone,
        email: email,
        ownerName: ownerName,
        shopName: shopName,
        address: address,
        latitude: latitude,
        longitude: longitude,
        licenseNumber: licenseNumber,
        password: password,
        whatsappNumber: whatsappNumber,
        alternativePhone: alternativePhone,
        gstinNo: gstinNo,
        bankAccountNo: bankAccountNo,
        bankIfscCode: bankIfscCode,
        bankName: bankName,
      );
      
      final shopId = response.data['shop_id'];
      if (shopId != null && (drugLicenseFile != null || panCardFile != null || regCertFile != null)) {
        await _authService.uploadShopDocuments(
          shopId: shopId,
          drugLicense: drugLicenseFile,
          panCard: panCardFile,
          registrationCert: regCertFile,
        );
      }

      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.response?.data['detail'] ?? e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> demoLogin(String phoneNumber) async {
    final demoUser = UserModel(
      customerId: 'demo_user_123',
      phoneNumber: phoneNumber,
      fullName: 'Demo User',
      token: 'demo_token_xyz',
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', demoUser.toJson());
    state = state.copyWith(user: demoUser, isLoading: false);
  }

  Future<bool> updateProfile({
    String? fullName,
    File? profilePhoto,
  }) async {
    final user = state.user;
    if (user == null || user.customerId == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.updateProfile(
        customerId: user.customerId!,
        fullName: fullName,
        profilePhoto: profilePhoto,
      );

      final updatedUser = user.copyWith(
        fullName: fullName,
        profilePhoto: profilePhoto?.path,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', updatedUser.toJson());

      state = state.copyWith(user: updatedUser, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    final user = state.user;
    if (user == null || user.customerId == null || user.token == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.deleteCustomer(user.customerId!, user.token!);
      await logout();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    final user = state.user;
    if (user != null && user.token != null && user.customerId != null) {
      try {
        if (user.role == 'customer' || user.role == null) {
          await _authService.logout(user.customerId!, user.token!);
        }
      } catch (e) {
        // Ignore backend errors so the user can still log out locally
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    state = AuthState();
  }
}
