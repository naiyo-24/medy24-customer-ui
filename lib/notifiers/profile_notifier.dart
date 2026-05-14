import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/auth_services.dart';

class ProfileState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  ProfileState({this.user, this.isLoading = false, this.error});

  ProfileState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref ref;
  final AuthService _authService = AuthService();

  ProfileNotifier(this.ref) : super(ProfileState()) {
    _syncWithAuth();
  }

  void _syncWithAuth() {
    ref.listen(authProvider, (previous, next) {
      if (next.user != null) {
        state = state.copyWith(user: next.user);
      } else {
        state = ProfileState();
      }
    });

    // Initial sync
    final authState = ref.read(authProvider);
    if (authState.user != null) {
      state = state.copyWith(user: authState.user);
    }
  }

  Future<void> fetchProfile() async {
    final currentUser = state.user;
    if (currentUser?.customerId == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.getProfile(currentUser!.customerId!);
      final user = UserModel.fromMap(response.data['user']);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? alternativePhoneNo,
    File? profilePhoto,
  }) async {
    final currentUser = state.user;
    if (currentUser?.customerId == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.updateProfile(
        customerId: currentUser!.customerId!,
        fullName: fullName,
        email: email,
        alternativePhoneNo: alternativePhoneNo,
        profilePhoto: profilePhoto,
      );

      final user = UserModel.fromMap(response.data['user']);
      state = state.copyWith(user: user, isLoading: false);

      // Update auth provider state too
      ref.read(authProvider.notifier).loadUser();

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
