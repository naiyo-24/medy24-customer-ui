import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/distributor_models.dart';
import '../services/b2b_service.dart';
import '../providers/b2b_graphql_provider.dart';

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

      // TODO: Replace with actual shop coordinates from user profile/location service
      const lat = 22.5726;
      const lng = 88.3639;

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
