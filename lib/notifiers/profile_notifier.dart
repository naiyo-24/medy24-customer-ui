import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      // Preserve the token from the current state
      final updatedUser = user.copyWith(token: currentUser.token);
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? alternativePhoneNo,
    String? status,
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
        status: status,
        profilePhoto: profilePhoto,
      );

      final user = UserModel.fromMap(response.data['user']);
      // Preserve the token from the current state
      final updatedUser = user.copyWith(token: currentUser.token);
      state = state.copyWith(user: updatedUser, isLoading: false);

      // Save updated user to SharedPreferences via AuthNotifier logic
      // But AuthNotifier's loadUser reads from prefs.
      // We should update the prefs here too or let AuthNotifier handle it.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', updatedUser.toJson());

      // Sync AuthNotifier state
      ref.read(authProvider.notifier).loadUser();

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> addAddress({
    required String address1,
    required String streetAddress,
    required double latitude,
    required double longitude,
  }) async {
    final currentUser = state.user;
    if (currentUser?.customerId == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.addAddress(
        customerId: currentUser!.customerId!,
        address1: address1,
        streetAddress: streetAddress,
        latitude: latitude,
        longitude: longitude,
      );

      final newAddress = response.data['data']['addSavedAddress'];
      final addresses = List<dynamic>.from(currentUser.savedAddresses ?? []);
      addresses.add(newAddress);
      
      final updatedUser = currentUser.copyWith(savedAddresses: addresses);
      state = state.copyWith(user: updatedUser, isLoading: false);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', updatedUser.toJson());
      ref.read(authProvider.notifier).loadUser();

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    final currentUser = state.user;
    if (currentUser?.customerId == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Get fresh Firebase ID token
      final firebaseToken = await FirebaseAuth.instance.currentUser
          ?.getIdToken();
      if (firebaseToken == null) throw 'Authentication token expired';

      final response = await _authService.deleteAddress(
        customerId: currentUser!.customerId!,
        addressId: addressId,
        token: firebaseToken,
      );

      final success = response.data['data']['deleteSavedAddress'] == true;
      if (success) {
        final addresses = List<dynamic>.from(currentUser.savedAddresses ?? [])
            ..removeWhere((addr) => addr['address_id'] == addressId);
            
        final updatedUser = currentUser.copyWith(savedAddresses: addresses);
        state = state.copyWith(user: updatedUser, isLoading: false);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', updatedUser.toJson());
        ref.read(authProvider.notifier).loadUser();
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to delete address');
      }

      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
