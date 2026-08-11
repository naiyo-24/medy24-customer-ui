import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/foundation.dart';
import '../models/global_lab_test.dart';
import '../models/lab_package.dart';
import '../services/lab_test_services.dart';

class LabTestState {
  final Set<String> selectedTestIds;
  final List<GlobalLabTest> searchResults;
  final bool isLoadingSearch;
  final List<LabPackage> matchedLabs;
  final bool isLoadingLabs;
  
  final GlobalLabTest? selectedTestDetails;
  final List<LabPackage> labsForSelectedTest;
  final bool isLoadingLabsForTest;

  LabTestState({
    this.selectedTestIds = const {},
    this.searchResults = const [],
    this.isLoadingSearch = false,
    this.matchedLabs = const [],
    this.isLoadingLabs = false,
    this.selectedTestDetails,
    this.labsForSelectedTest = const [],
    this.isLoadingLabsForTest = false,
  });

  LabTestState copyWith({
    Set<String>? selectedTestIds,
    List<GlobalLabTest>? searchResults,
    bool? isLoadingSearch,
    List<LabPackage>? matchedLabs,
    bool? isLoadingLabs,
    GlobalLabTest? selectedTestDetails,
    List<LabPackage>? labsForSelectedTest,
    bool? isLoadingLabsForTest,
  }) {
    return LabTestState(
      selectedTestIds: selectedTestIds ?? this.selectedTestIds,
      searchResults: searchResults ?? this.searchResults,
      isLoadingSearch: isLoadingSearch ?? this.isLoadingSearch,
      matchedLabs: matchedLabs ?? this.matchedLabs,
      isLoadingLabs: isLoadingLabs ?? this.isLoadingLabs,
      selectedTestDetails: selectedTestDetails ?? this.selectedTestDetails,
      labsForSelectedTest: labsForSelectedTest ?? this.labsForSelectedTest,
      isLoadingLabsForTest: isLoadingLabsForTest ?? this.isLoadingLabsForTest,
    );
  }
}

class LabTestNotifier extends StateNotifier<LabTestState> {
  final LabTestService _service;

  LabTestNotifier(this._service) : super(LabTestState()) {
    // Fetch initial popular tests
    searchTests("");
  }

  Future<void> selectTestAndFindLabs(GlobalLabTest test) async {
    state = state.copyWith(
      selectedTestDetails: test,
      isLoadingLabsForTest: true,
      labsForSelectedTest: [],
    );
    try {
      final response = await _service.findLabsForSelectedTests([test.testId]);
      final data = response.data['data']['findLabsForSelectedTests'] as List;
      final labs = data.map((json) => LabPackage.fromJson(json)).toList();
      state = state.copyWith(labsForSelectedTest: labs, isLoadingLabsForTest: false);
    } catch (e, stackTrace) {
      debugPrint('Error in findLabsForTest: $e');
      debugPrint('StackTrace: $stackTrace');
      state = state.copyWith(isLoadingLabsForTest: false);
    }
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
    } catch (e, stackTrace) {
      debugPrint('Error in searchTests: $e');
      debugPrint('StackTrace: $stackTrace');
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
    } catch (e, stackTrace) {
      debugPrint('Error in findLabs: $e');
      debugPrint('StackTrace: $stackTrace');
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

final labTestsByLabIdProvider = FutureProvider.family<List<GlobalLabTest>, String>((ref, labId) async {
  final service = ref.watch(labTestServiceProvider);
  final response = await service.getLabTestsByLabId(labId);
  if (response.data != null && response.data['data'] != null) {
    final list = response.data['data'] as List;
    return list.map((json) => GlobalLabTest.fromJson(json)).toList();
  }
  return [];
});
