import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/b2b_cart_service.dart';
import '../providers/b2b_graphql_provider.dart';

class B2BCartState {
  final bool isLoading;
  final String? activeDistributorId;
  final double totalEstimatedPrice;
  final String? error;
  final bool requiresCartClearance;

  B2BCartState({
    this.isLoading = false,
    this.activeDistributorId,
    this.totalEstimatedPrice = 0.0,
    this.error,
    this.requiresCartClearance = false,
  });

  B2BCartState copyWith({
    bool? isLoading,
    String? activeDistributorId,
    double? totalEstimatedPrice,
    String? error,
    bool? requiresCartClearance,
  }) {
    return B2BCartState(
      isLoading: isLoading ?? this.isLoading,
      activeDistributorId: activeDistributorId ?? this.activeDistributorId,
      totalEstimatedPrice: totalEstimatedPrice ?? this.totalEstimatedPrice,
      error: error,
      requiresCartClearance: requiresCartClearance ?? this.requiresCartClearance,
    );
  }
}

class B2BCartNotifier extends Notifier<B2BCartState> {
  @override
  B2BCartState build() {
    return B2BCartState();
  }

  Future<void> addItem({
    required String distributorId,
    required String inventoryId,
    required int qtyBoxes,
    required double ptr,
  }) async {
    state = state.copyWith(isLoading: true, error: null, requiresCartClearance: false);

    try {
      final client = await ref.read(b2bGraphQLClientProvider.future);
      final service = B2BCartService(client);

      final result = await service.addToCart(
        distributorId: distributorId,
        inventoryId: inventoryId,
        qtyBoxes: qtyBoxes,
        ptr: ptr,
      );

      state = state.copyWith(
        isLoading: false,
        activeDistributorId: result['activeDistributorId'],
        totalEstimatedPrice: (result['totalEstimatedPrice'] ?? 0).toDouble(),
      );

    } catch (e) {
      final errorString = e.toString();
      
      // The Swiggy Rule Catch: If backend complains about a different distributor
      if (errorString.contains('another distributor')) {
        state = state.copyWith(
          isLoading: false,
          requiresCartClearance: true, // This tells the UI to show the dialog
          error: 'Your cart contains items from another distributor.',
        );
      } else {
        state = state.copyWith(isLoading: false, error: errorString);
      }
    }
  }

  Future<void> clearCart() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final client = await ref.read(b2bGraphQLClientProvider.future);
      final service = B2BCartService(client);
      
      await service.clearCart();
      
      // Reset state entirely
      state = B2BCartState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final b2bCartProvider = NotifierProvider<B2BCartNotifier, B2BCartState>(() {
  return B2BCartNotifier();
});
