import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/global_lab_test.dart';
import '../models/lab_package.dart';
import '../services/lab_test_services.dart';

class LabTestState {
  final Set<String> selectedTestIds;
  final List<GlobalLabTest> searchResults;
  final bool isLoadingSearch;
  final List<LabPackage> matchedLabs;
  final bool isLoadingLabs;

  LabTestState({
    this.selectedTestIds = const {},
    this.searchResults = const [],
    this.isLoadingSearch = false,
    this.matchedLabs = const [],
    this.isLoadingLabs = false,
  });

  LabTestState copyWith({
    Set<String>? selectedTestIds,
    List<GlobalLabTest>? searchResults,
    bool? isLoadingSearch,
    List<LabPackage>? matchedLabs,
    bool? isLoadingLabs,
  }) {
    return LabTestState(
      selectedTestIds: selectedTestIds ?? this.selectedTestIds,
      searchResults: searchResults ?? this.searchResults,
      isLoadingSearch: isLoadingSearch ?? this.isLoadingSearch,
      matchedLabs: matchedLabs ?? this.matchedLabs,
      isLoadingLabs: isLoadingLabs ?? this.isLoadingLabs,
    );
  }
}

class LabTestNotifier extends StateNotifier<LabTestState> {
  final LabTestService _service;

  LabTestNotifier(this._service) : super(LabTestState()) {
    // Fetch initial popular tests
    searchTests("");
  }

  void toggleTestSelection(String testId) {
    final newSet = Set<String>.from(state.selectedTestIds);
    if (newSet.contains(testId)) {
      newSet.remove(testId);
    } else {
      newSet.add(testId);
    }
    state = state.copyWith(selectedTestIds: newSet);
  }

  void clearSelections() {
    state = state.copyWith(selectedTestIds: {});
  }

  Future<void> searchTests(String query) async {
    state = state.copyWith(isLoadingSearch: true);
    try {
      final response = await _service.searchLabTests(query);
      final data = response.data['data']['searchLabTests'] as List;
      final results = data.map((json) => GlobalLabTest.fromJson(json)).toList();
      state = state.copyWith(searchResults: results, isLoadingSearch: false);
    } catch (e) {
      state = state.copyWith(isLoadingSearch: false);
      // Handle error gracefully in real app
    }
  }

  Future<void> findLabs() async {
    if (state.selectedTestIds.isEmpty) return;
    state = state.copyWith(isLoadingLabs: true);
    try {
      final response = await _service.findLabsForSelectedTests(state.selectedTestIds.toList());
      final data = response.data['data']['findLabsForSelectedTests'] as List;
      final labs = data.map((json) => LabPackage.fromJson(json)).toList();
      state = state.copyWith(matchedLabs: labs, isLoadingLabs: false);
    } catch (e) {
      state = state.copyWith(isLoadingLabs: false);
      // Handle error gracefully in real app
    }
  }
}

final labTestServiceProvider = Provider<LabTestService>((ref) {
  return LabTestService();
});

final labTestProvider = StateNotifierProvider<LabTestNotifier, LabTestState>((ref) {
  final service = ref.watch(labTestServiceProvider);
  return LabTestNotifier(service);
});
