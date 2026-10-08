import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/b2b_medicine.dart';
import '../services/b2b_service.dart';
import '../providers/b2b_graphql_provider.dart';

class B2BSearchState {
  final bool isLoading;
  final List<B2BMedicineModel> searchResults;
  final String? error;

  B2BSearchState({
    this.isLoading = false,
    this.searchResults = const [],
    this.error,
  });

  B2BSearchState copyWith({
    bool? isLoading,
    List<B2BMedicineModel>? searchResults,
    String? error,
  }) {
    return B2BSearchState(
      isLoading: isLoading ?? this.isLoading,
      searchResults: searchResults ?? this.searchResults,
      error: error,
    );
  }
}

class B2BSearchNotifier extends Notifier<B2BSearchState> {
  @override
  B2BSearchState build() {
    return B2BSearchState();
  }

  Future<void> searchMedicines(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: [], error: null);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Await the GraphQL client from your existing FutureProvider
      final client = await ref.read(b2bGraphQLClientProvider.future);
      final service = B2BService(client);

      const lat = 22.5726;
      const lng = 88.3639;

      final results = await service.searchB2BMedicines(query, lat, lng);
      state = state.copyWith(isLoading: false, searchResults: results);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// The Provider to expose this Notifier
final b2bSearchProvider = NotifierProvider<B2BSearchNotifier, B2BSearchState>(
  () {
    return B2BSearchNotifier();
  },
);
