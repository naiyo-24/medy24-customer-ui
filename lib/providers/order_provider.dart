import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../notifiers/order_notifier.dart';
import '../services/order_services.dart';
import 'profile_provider.dart';

final orderServiceProvider = Provider((ref) => OrderService());

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final service = ref.read(orderServiceProvider);
  final notifier = OrderNotifier(ref, service);

  // Refetch orders if customerId changes (login/logout scenario)
  ref.listen(profileProvider, (previous, next) {
    if (previous?.user?.customerId != next.user?.customerId) {
      if (next.user?.customerId != null) {
        notifier.fetchOrders(refresh: true);
      }
    }
  });

  return notifier;
});
