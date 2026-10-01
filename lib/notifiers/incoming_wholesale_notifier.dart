import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/b2b_order.dart';
import '../services/b2b_order_service.dart';
import '../providers/b2b_graphql_provider.dart';

class IncomingWholesaleState {
  final bool isLoading;
  final String? error;
  final List<B2BOrderModel> orders;

  IncomingWholesaleState({
    this.isLoading = false,
    this.error,
    this.orders = const [],
  });

  IncomingWholesaleState copyWith({
    bool? isLoading,
    String? error,
    List<B2BOrderModel>? orders,
  }) {
    return IncomingWholesaleState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      orders: orders ?? this.orders,
    );
  }
}

class IncomingWholesaleNotifier extends StateNotifier<IncomingWholesaleState> {
  final Ref ref;

  IncomingWholesaleNotifier(this.ref) : super(IncomingWholesaleState());

  Future<void> fetchOrders(String shopId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final client = await ref.read(b2bGraphQLClientProvider.future);
      final service = B2BOrderService(client);
      final orders = await service.fetchMyOrders(shopId);
      state = state.copyWith(isLoading: false, orders: orders);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final incomingWholesaleProvider = StateNotifierProvider<IncomingWholesaleNotifier, IncomingWholesaleState>((ref) {
  return IncomingWholesaleNotifier(ref);
});
