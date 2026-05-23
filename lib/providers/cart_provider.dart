import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifiers/cart_notifier.dart';
import '../services/cart_services.dart';
import 'profile_provider.dart';

final cartServiceProvider = Provider((ref) => CartService());

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final notifier = CartNotifier(ref);

  // Refetch cart if customerId changes (login/logout scenario)
  ref.listen(profileProvider, (previous, next) {
    if (previous?.user?.customerId != next.user?.customerId) {
      if (next.user?.customerId != null) {
        notifier.fetchCart();
      } else {
        notifier.clearCartLocal();
      }
    }
  });

  return notifier;
});
