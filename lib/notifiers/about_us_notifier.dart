import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/about_us_services.dart';
import '../models/about_us.dart';

class AboutUsState {
  final List<AboutUsModel> aboutUsList;
  final bool isLoading;
  final String? error;

  AboutUsState({
    this.aboutUsList = const [],
    this.isLoading = false,
    this.error,
  });

  AboutUsState copyWith({
    List<AboutUsModel>? aboutUsList,
    bool? isLoading,
    String? error,
  }) {
    return AboutUsState(
      aboutUsList: aboutUsList ?? this.aboutUsList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AboutUsNotifier extends StateNotifier<AboutUsState> {
  final AboutUsServices _services;

  AboutUsNotifier(this._services) : super(AboutUsState()) {
    fetchAboutUs();
  }

  Future<void> fetchAboutUs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _services.getAllAboutUs();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final list = data.map((e) => AboutUsModel.fromJson(e)).toList();
        state = state.copyWith(isLoading: false, aboutUsList: list);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['detail'] ?? 'Failed to fetch about us data',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
