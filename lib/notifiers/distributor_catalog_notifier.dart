import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/distributor_models.dart';
import '../services/b2b_service.dart';
import '../providers/b2b_graphql_provider.dart';

class DistributorCatalogState {
  final bool isLoading;
  final List<DistributorCatalogItemModel> catalog;
  final String? error;

  DistributorCatalogState({
    this.isLoading = false,
    this.catalog = const [],
    this.error,
  });

  DistributorCatalogState copyWith({
    bool? isLoading,
    List<DistributorCatalogItemModel>? catalog,
    String? error,
  }) {
    return DistributorCatalogState(
      isLoading: isLoading ?? this.isLoading,
      catalog: catalog ?? this.catalog,
      error: error,
    );
  }
}

class DistributorCatalogNotifier extends Notifier<DistributorCatalogState> {
  @override
  DistributorCatalogState build() {
    return DistributorCatalogState();
  }

  Future<void> fetchCatalog(String distributorId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final client = await ref.read(b2bGraphQLClientProvider.future);
      final service = B2BService(client);

      final rawData = await service.getDistributorCatalog(distributorId);
      final catalog = rawData.map((e) => DistributorCatalogItemModel.fromJson(e)).toList();
      state = state.copyWith(isLoading: false, catalog: catalog);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final distributorCatalogProvider = NotifierProvider<DistributorCatalogNotifier, DistributorCatalogState>(() {
  return DistributorCatalogNotifier();
});
