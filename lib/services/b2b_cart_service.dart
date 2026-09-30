import 'package:graphql_flutter/graphql_flutter.dart';

class B2BCartService {
  final GraphQLClient client;

  B2BCartService(this.client);

  static const String addToCartMutation = r'''
    mutation AddToB2bCart($distributorId: String!, $inventoryId: String!, $qtyBoxes: Int!, $ptr: Float!) {
      addToB2bCart(distributorId: $distributorId, inventoryId: $inventoryId, qtyBoxes: $qtyBoxes, ptr: $ptr) {
        cartId
        activeDistributorId
        totalEstimatedPrice
      }
    }
  ''';

  static const String clearCartMutation = r'''
    mutation ClearB2bCart {
      clearB2bCart {
        cartId
        activeDistributorId
        totalEstimatedPrice
      }
    }
  ''';

  Future<Map<String, dynamic>> addToCart({
    required String distributorId,
    required String inventoryId,
    required int qtyBoxes,
    required double ptr,
  }) async {
    final MutationOptions options = MutationOptions(
      document: gql(addToCartMutation),
      variables: {
        'distributorId': distributorId,
        'inventoryId': inventoryId,
        'qtyBoxes': qtyBoxes,
        'ptr': ptr,
      },
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      final errorMessage = result.exception?.graphqlErrors.isNotEmpty == true
          ? result.exception!.graphqlErrors.first.message
          : 'Failed to add item to cart.';
      
      // We throw the exact error so Riverpod can catch the "another distributor" rule
      throw Exception(errorMessage);
    }

    return result.data?['addToB2bCart'] ?? {};
  }

  Future<void> clearCart() async {
    final MutationOptions options = MutationOptions(
      document: gql(clearCartMutation),
    );
    await client.mutate(options);
  }
}
