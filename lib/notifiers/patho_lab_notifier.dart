import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patho_lab.dart';
import '../services/patho_lab_services.dart';

class PathoLabState {
  final List<PathoLabModel> labs;
  final bool isLoading;
  final String? error;
  final PathoLabModel? selectedLab;

  PathoLabState({
    this.labs = const [],
    this.isLoading = false,
    this.error,
    this.selectedLab,
  });

  PathoLabState copyWith({
    List<PathoLabModel>? labs,
    bool? isLoading,
    String? error,
    PathoLabModel? selectedLab,
  }) {
    return PathoLabState(
      labs: labs ?? this.labs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedLab: selectedLab ?? this.selectedLab,
    );
  }
}

class PathoLabNotifier extends StateNotifier<PathoLabState> {
  final PathoLabService _service;

  PathoLabNotifier(this._service) : super(PathoLabState());

  Future<void> fetchLabs({String? name, String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.getAllLabs(name: name, status: status);
      if (response.statusCode == 200) {
        final List labsJson = response.data['labs'] ?? [];
        final labs = labsJson.map((l) => PathoLabModel.fromJson(l)).toList();
        state = state.copyWith(labs: labs, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: "Failed to load labs");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchLabById(String labId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.getLabById(labId);
      if (response.statusCode == 200) {
        final lab = PathoLabModel.fromJson(response.data);
        state = state.copyWith(selectedLab: lab, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Failed to load lab details",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
