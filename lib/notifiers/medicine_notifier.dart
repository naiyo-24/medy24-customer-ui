import 'package:flutter_riverpod/legacy.dart';
import '../models/medicine.dart';
import '../services/medicine_services.dart';

class MedicineState {
  final List<MedicineModel> medicines;
  final List<MedicineModel> searchResults;
  final MedicineModel? selectedMedicine;
  final bool isLoading;
  final bool isFetchingMore;
  final int currentPage;
  final bool hasMore;
  final bool isFetchingMoreSearch;
  final int searchPage;
  final bool hasMoreSearch;
  final String? error;
  final String? lastSearchTerm;
  final List<String>? lastPriceRange;
  final String? lastCategory;
  final List<String>? listPriceRange;

  MedicineState({
    this.medicines = const [],
    this.searchResults = const [],
    this.selectedMedicine,
    this.isLoading = false,
    this.isFetchingMore = false,
    this.currentPage = 1,
    this.hasMore = true,
    this.isFetchingMoreSearch = false,
    this.searchPage = 1,
    this.hasMoreSearch = true,
    this.error,
    this.lastSearchTerm,
    this.lastPriceRange,
    this.lastCategory,
    this.listPriceRange,
  });

  MedicineState copyWith({
    List<MedicineModel>? medicines,
    List<MedicineModel>? searchResults,
    MedicineModel? selectedMedicine,
    bool? isLoading,
    bool? isFetchingMore,
    int? currentPage,
    bool? hasMore,
    bool? isFetchingMoreSearch,
    int? searchPage,
    bool? hasMoreSearch,
    String? error,
    String? lastSearchTerm,
    List<String>? lastPriceRange,
    String? lastCategory,
    List<String>? listPriceRange,
  }) {
    return MedicineState(
      medicines: medicines ?? this.medicines,
      searchResults: searchResults ?? this.searchResults,
      selectedMedicine: selectedMedicine ?? this.selectedMedicine,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isFetchingMoreSearch: isFetchingMoreSearch ?? this.isFetchingMoreSearch,
      searchPage: searchPage ?? this.searchPage,
      hasMoreSearch: hasMoreSearch ?? this.hasMoreSearch,
      error: error,
      lastSearchTerm: lastSearchTerm ?? this.lastSearchTerm,
      lastPriceRange: lastPriceRange ?? this.lastPriceRange,
      lastCategory: lastCategory ?? this.lastCategory,
      listPriceRange: listPriceRange ?? this.listPriceRange,
    );
  }
}

class MedicineNotifier extends StateNotifier<MedicineState> {
  final MedicineService _service = MedicineService();

  MedicineNotifier() : super(MedicineState());

  Future<void> fetchAllMedicines({
    bool loadMore = false,
    List<String>? priceRange,
    bool clearFilter = false,
  }) async {
    final newPriceRange = clearFilter
        ? null
        : (priceRange ?? state.listPriceRange);

    if (loadMore) {
      if (state.isFetchingMore || !state.hasMore) return;
      state = state.copyWith(isFetchingMore: true, error: null);
    } else {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentPage: 1,
        hasMore: true,
        listPriceRange: newPriceRange,
      );
    }

    try {
      final page = loadMore ? state.currentPage + 1 : 1;

      final response = (newPriceRange != null && newPriceRange.isNotEmpty)
          ? await _service.searchMedicines(
              priceRange: newPriceRange,
              page: page,
            )
          : await _service.getAllMedicines(page: page);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data['data'] ?? {};
        final List data = responseData['searchMedicines'] ?? [];
        final newMedicines = data.map((m) => MedicineModel.fromMap(m)).toList();

        final hasMoreData =
            newMedicines.isNotEmpty && newMedicines.length >= 20;

        state = state.copyWith(
          medicines: loadMore
              ? [...state.medicines, ...newMedicines]
              : newMedicines,
          isLoading: false,
          isFetchingMore: false,
          currentPage: page,
          hasMore: hasMoreData,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isFetchingMore: false,
          error: "Failed to load medicines",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> fetchMedicineById(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.getMedicineById(id);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data['data'] ?? {};
        final medicine = MedicineModel.fromMap(responseData['getMedicineById'] ?? {});
        state = state.copyWith(selectedMedicine: medicine, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to load medicine details",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchMedicines({
    String? searchTerm,
    List<String>? priceRange,
    String? category,
    bool loadMore = false,
  }) async {
    final sTerm = searchTerm ?? state.lastSearchTerm;
    final pRange = priceRange ?? state.lastPriceRange;
    final cat = category ?? state.lastCategory;

    if ((sTerm == null || sTerm.isEmpty) &&
        (pRange == null || pRange.isEmpty) &&
        (cat == null || cat.isEmpty)) {
      state = state.copyWith(
        searchResults: [],
        lastSearchTerm: null,
        lastPriceRange: null,
        lastCategory: null,
      );
      return;
    }

    if (loadMore) {
      if (state.isFetchingMoreSearch || !state.hasMoreSearch) return;
      state = state.copyWith(isFetchingMoreSearch: true, error: null);
    } else {
      state = state.copyWith(
        isLoading: true,
        error: null,
        searchPage: 1,
        hasMoreSearch: true,
        lastSearchTerm: sTerm,
        lastPriceRange: pRange,
        lastCategory: cat,
      );
    }

    try {
      final page = loadMore ? state.searchPage + 1 : 1;
      final response = await _service.searchMedicines(
        searchTerm: sTerm,
        priceRange: pRange,
        category: cat,
        page: page,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data['data'] ?? {};
        final List data = responseData['searchMedicines'] ?? [];
        final results = data.map((m) => MedicineModel.fromMap(m)).toList();

        final hasMoreData = results.isNotEmpty && results.length >= 20;

        state = state.copyWith(
          searchResults: loadMore
              ? [...state.searchResults, ...results]
              : results,
          isLoading: false,
          isFetchingMoreSearch: false,
          searchPage: page,
          hasMoreSearch: hasMoreData,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isFetchingMoreSearch: false,
          error: "Search failed",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isFetchingMoreSearch: false,
        error: e.toString(),
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(
      searchResults: [],
      lastSearchTerm: null,
      lastPriceRange: null,
      lastCategory: null,
      searchPage: 1,
      hasMoreSearch: true,
    );
  }

  void selectMedicine(MedicineModel medicine) {
    state = state.copyWith(selectedMedicine: medicine);
  }
}
