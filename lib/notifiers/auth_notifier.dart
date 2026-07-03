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
      final authenticatedUser = UserModel(
        customerId: customerId,
        phoneNumber: phoneNumber,
        fullName: fullName ?? 'Customer',
        email: email,
        alternativePhoneNo: alternativePhoneNo,
        profilePhoto: profilePhoto?.path,
        token: backendToken,
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    state = AuthState();
  }
}
