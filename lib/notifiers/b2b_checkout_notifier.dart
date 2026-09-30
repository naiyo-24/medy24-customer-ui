import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/b2b_checkout_service.dart';
import '../providers/b2b_graphql_provider.dart';

class B2BCheckoutState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? razorpayConfig;
  final String? successfulPoId;

  B2BCheckoutState({
    this.isLoading = false,
    this.error,
    this.razorpayConfig,
    this.successfulPoId,
  });

  B2BCheckoutState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? razorpayConfig,
    String? successfulPoId,
  }) {
    return B2BCheckoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      razorpayConfig: razorpayConfig,
      successfulPoId: successfulPoId ?? this.successfulPoId,
    );
  }
}

class B2BCheckoutNotifier extends Notifier<B2BCheckoutState> {
  @override
  B2BCheckoutState build() {
    return B2BCheckoutState();
  }

  Future<void> checkoutCart(String paymentTerms) async {
    state = state.copyWith(isLoading: true, error: null, razorpayConfig: null);

    try {
      final client = await ref.read(b2bGraphQLClientProvider.future);
      final service = B2BCheckoutService(client);

      final checkoutResult = await service.processCheckout(paymentTerms);
      final poId = checkoutResult['poId'];

      if (paymentTerms == 'prepaid') {
        final rzpConfig = await service.initiateRazorpay(poId);
        
        state = state.copyWith(
          isLoading: false,
          razorpayConfig: {
            ...rzpConfig,
            'poId': poId,
          },
        );
      } else {
        state = state.copyWith(isLoading: false, successfulPoId: poId);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void resetState() {
    state = B2BCheckoutState();
  }
}

final b2bCheckoutProvider = NotifierProvider<B2BCheckoutNotifier, B2BCheckoutState>(() {
  return B2BCheckoutNotifier();
});
