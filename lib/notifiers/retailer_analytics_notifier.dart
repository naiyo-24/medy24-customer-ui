import 'package:flutter_riverpod/legacy.dart';
import 'package:dio/dio.dart';
import '../services/api_url.dart';

class RetailerAnalyticsState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? data;

  RetailerAnalyticsState({
    this.isLoading = false,
    this.error,
    this.data,
  });

  RetailerAnalyticsState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? data,
  }) {
    return RetailerAnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      data: data ?? this.data,
    );
  }
}

class RetailerAnalyticsNotifier extends StateNotifier<RetailerAnalyticsState> {
  final Dio _dio = Dio();

  RetailerAnalyticsNotifier() : super(RetailerAnalyticsState());

  Future<void> fetchAnalytics(String shopId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(ApiUrl.pharmacyDashboard(shopId));
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false, data: response.data);
      } else {
        state = state.copyWith(
            isLoading: false, error: 'Failed to fetch analytics');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final retailerAnalyticsProvider =
    StateNotifierProvider<RetailerAnalyticsNotifier, RetailerAnalyticsState>(
        (ref) => RetailerAnalyticsNotifier());
