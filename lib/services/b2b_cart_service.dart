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
        items {
          inventoryId
          medicineName
          moq
          qtyBoxes
          ptr
          gstPercentage
        }
      }
    }
  ''';

  static const String clearCartMutation = r'''
    mutation ClearB2bCart {
      clearB2bCart {
        cartId
        activeDistributorId
        totalEstimatedPrice
        items {
          inventoryId
          medicineName
          moq
          qtyBoxes
          ptr
          gstPercentage
        }
      }
    }
  ''';

  static const String removeFromCartMutation = r'''
    mutation RemoveFromB2bCart($inventoryId: String!) {
      removeFromB2bCart(inventoryId: $inventoryId) {
        cartId
        activeDistributorId
        totalEstimatedPrice
        items {
          inventoryId
          medicineName
          moq
          qtyBoxes
          ptr
          gstPercentage
        }
      }
    }
  ''';

  static const String updateCartQtyMutation = r'''
    mutation UpdateB2bCartQty($inventoryId: String!, $newQty: Int!) {
      updateB2bCartQty(inventoryId: $inventoryId, newQty: $newQty) {
        cartId
        activeDistributorId
        totalEstimatedPrice
        items {
          inventoryId
          medicineName
          moq
          qtyBoxes
          ptr
          gstPercentage
        }
      }
    }
  ''';

  static const String getCartQuery = r'''
    query GetMyB2bCart {
      getMyB2bCart {
        cartId
        activeDistributorId
        totalEstimatedPrice
        items {
          inventoryId
          medicineName
          moq
          qtyBoxes
          ptr
          gstPercentage
        }
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

  Future<Map<String, dynamic>> removeFromCart(String inventoryId) async {
    final MutationOptions options = MutationOptions(
      document: gql(removeFromCartMutation),
      variables: {
        'inventoryId': inventoryId,
      },
    );
    final QueryResult result = await client.mutate(options);
    if (result.hasException) {
      throw Exception(result.exception?.graphqlErrors.firstOrNull?.message ?? 'Failed to remove item');
    }
    return result.data?['removeFromB2bCart'] ?? {};
  }

  Future<Map<String, dynamic>> updateCartQty(String inventoryId, int newQty) async {
    final MutationOptions options = MutationOptions(
      document: gql(updateCartQtyMutation),
      variables: {
        'inventoryId': inventoryId,
        'newQty': newQty,
      },
    );
    final QueryResult result = await client.mutate(options);
    if (result.hasException) {
      throw Exception(result.exception?.graphqlErrors.firstOrNull?.message ?? 'Failed to update quantity');
    }
    return result.data?['updateB2bCartQty'] ?? {};
  }

  Future<Map<String, dynamic>?> fetchCart() async {
    final QueryOptions options = QueryOptions(
      document: gql(getCartQuery),
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final QueryResult result = await client.query(options);
    if (result.hasException) {
      return null;
    }
    return result.data?['getMyB2bCart'];
  }
}
