import 'package:graphql_flutter/graphql_flutter.dart';

class B2BCheckoutService {
  final GraphQLClient client;

  B2BCheckoutService(this.client);

  static const String checkoutMutation = r'''
    mutation CheckoutB2BCart($paymentTerms: String!) {
      checkoutB2bCart(paymentTerms: $paymentTerms) {
        poId
        subtotal
        totalInvoiceAmount
        paymentTerms
        poStatus
      }
    }
  ''';

  static const String createRazorpayMutation = r'''
    mutation CreateB2BRazorpayOrder($poId: String!) {
      createB2bRazorpayOrder(poId: $poId) {
        razorpayOrderId
        amountInPaise
        currency
        keyId
      }
    }
  ''';

  static const String verifyPaymentMutation = r'''
    mutation VerifyB2bPayment(
      $razorpayOrderId: String!
      $razorpayPaymentId: String!
      $razorpaySignature: String!
      $poId: String!
    ) {
      verifyB2bPayment(
        razorpayOrderId: $razorpayOrderId
        razorpayPaymentId: $razorpayPaymentId
        razorpaySignature: $razorpaySignature
        poId: $poId
      )
    }
  ''';

  Future<Map<String, dynamic>> processCheckout(String paymentTerms) async {
    final MutationOptions options = MutationOptions(
      document: gql(checkoutMutation),
      variables: {'paymentTerms': paymentTerms},
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception?.graphqlErrors.isNotEmpty == true
          ? result.exception!.graphqlErrors.first.message
          : 'Checkout failed.');
    }
    return result.data?['checkoutB2bCart'] ?? {};
  }

  Future<Map<String, dynamic>> initiateRazorpay(String poId) async {
    final MutationOptions options = MutationOptions(
      document: gql(createRazorpayMutation),
      variables: {'poId': poId},
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      throw Exception('Failed to initialize Razorpay.');
    }
    return result.data?['createB2bRazorpayOrder'] ?? {};
  }

  Future<void> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String poId,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(verifyPaymentMutation),
      variables: {
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
        'poId': poId,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      final errMsg = result.exception?.graphqlErrors.isNotEmpty == true
          ? result.exception!.graphqlErrors.first.message
          : 'Payment verification failed.';
      throw Exception(errMsg);
    }
  }
}
