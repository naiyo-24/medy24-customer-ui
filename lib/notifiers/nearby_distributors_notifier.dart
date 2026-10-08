import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/distributor_models.dart';
import '../services/b2b_service.dart';
import '../providers/b2b_graphql_provider.dart';
import '../providers/auth_provider.dart';
import 'package:geolocator/geolocator.dart';

class NearbyDistributorsState {
  final bool isLoading;
  final List<NearbyDistributorModel> distributors;
  final String? error;

  NearbyDistributorsState({
    this.isLoading = false,
    this.distributors = const [],
    this.error,
  });

  NearbyDistributorsState copyWith({
    bool? isLoading,
    List<NearbyDistributorModel>? distributors,
    String? error,
  }) {
    return NearbyDistributorsState(
      isLoading: isLoading ?? this.isLoading,
      distributors: distributors ?? this.distributors,
      error: error,
    );
  }
}

class NearbyDistributorsNotifier extends Notifier<NearbyDistributorsState> {
  @override
  NearbyDistributorsState build() {
    return NearbyDistributorsState();
  }

  Future<void> fetchNearbyDistributors() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final client = await ref.read(b2bGraphQLClientProvider.future);
      final service = B2BService(client);

      double lat = 22.5726;
      double lng = 88.3639;

      final authState = ref.read(authProvider);
      final user = authState.user;

      if (user != null && user.savedAddresses != null && user.savedAddresses!.isNotEmpty) {
        final address = user.savedAddresses!.first;
        if (address['latitude'] != null && address['longitude'] != null) {
          lat = double.tryParse(address['latitude'].toString()) ?? lat;
          lng = double.tryParse(address['longitude'].toString()) ?? lng;
        } else if (address['lat'] != null && address['lng'] != null) {
          lat = double.tryParse(address['lat'].toString()) ?? lat;
          lng = double.tryParse(address['lng'].toString()) ?? lng;
        }
      } else {
        try {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (serviceEnabled) {
            LocationPermission permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
              final position = await Geolocator.getCurrentPosition();
              lat = position.latitude;
              lng = position.longitude;
            }
          }
        } catch (_) {
          // Fallback to default coordinates if location fails
        }
      }

      final rawData = await service.getNearbyDistributors(lat, lng);
      final distributors = rawData.map((e) => NearbyDistributorModel.fromJson(e)).toList();
      state = state.copyWith(isLoading: false, distributors: distributors);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final nearbyDistributorsProvider = NotifierProvider<NearbyDistributorsNotifier, NearbyDistributorsState>(() {
  return NearbyDistributorsNotifier();
});
