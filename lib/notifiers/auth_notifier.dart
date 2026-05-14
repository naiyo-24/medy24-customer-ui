import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isOtpSent = false,
    this.isUserExists = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isOtpSent,
    bool? isUserExists,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isUserExists: isUserExists ?? this.isUserExists,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(AuthState()) {
    loadUser();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      state = state.copyWith(user: UserModel.fromJson(userJson));
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
    File? profilePhoto,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.verifyOtp(
        token: token,
        phoneNumber: phoneNumber,
        fullName: fullName,
        profilePhoto: profilePhoto,
      );

      final user = UserModel.fromMap(response.data['user']);
      final backendToken = response.data['backend_token'];
      final authenticatedUser = user.copyWith(token: backendToken);

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
