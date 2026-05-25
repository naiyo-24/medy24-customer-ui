import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../notifiers/order_notifier.dart';
import '../services/order_services.dart';
import 'profile_provider.dart';

final orderServiceProvider = Provider((ref) {
  final service = OrderService();
  ref.onDispose(() => service.dispose());
  return service;
});

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final service = ref.read(orderServiceProvider);
  final notifier = OrderNotifier(ref, service);

  // Manage websocket connection and fetch orders if customerId changes
  ref.listen(profileProvider, (previous, next) {
    final previousId = previous?.user?.customerId;
    final nextId = next.user?.customerId;
    
    if (previousId != nextId) {
      if (nextId != null) {
        service.connect(nextId);
        notifier.fetchOrders(refresh: true);
      } else {
        service.disconnect();
      }
    }
  });

  return notifier;
});
