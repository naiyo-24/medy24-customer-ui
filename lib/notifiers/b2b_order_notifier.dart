import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/b2b_order.dart';
import '../services/b2b_order_service.dart';
import '../providers/b2b_graphql_provider.dart';

class B2BOrderState {
  final bool isLoading;
  final List<B2BOrderModel> orders;
  final String? error;

  B2BOrderState({
    this.isLoading = false,
    this.orders = const [],
    this.error,
  });
}

class B2BOrderNotifier extends Notifier<B2BOrderState> {
  @override
  B2BOrderState build() {
    return B2BOrderState();
  }

  Future<void> fetchOrders(String shopId) async {
    state = B2BOrderState(isLoading: true);
    try {
      final client = await ref.read(b2bGraphQLClientProvider.future);
      final service = B2BOrderService(client);
      
      final orders = await service.fetchMyOrders(shopId);
      state = B2BOrderState(isLoading: false, orders: orders);
    } catch (e) {
      state = B2BOrderState(isLoading: false, error: e.toString());
    }
  }
}

final b2bOrderProvider = NotifierProvider<B2BOrderNotifier, B2BOrderState>(() {
  return B2BOrderNotifier();
});
