import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/b2b_order.dart';

class B2BOrderService {
  final GraphQLClient client;

  B2BOrderService(this.client);

  static const String getOrdersQuery = r'''
    query GetMyB2BOrders($shopId: String!) {
      getB2bOrders(shopId: $shopId) {
        poId
        subtotal
        totalInvoiceAmount
        poStatus
        paymentTerms
        createdAt
        distributor {
          companyName
        }
        items {
          medicineId
          batchNumber
          qtyBoxes
          ptr
        }
      }
    }
  ''';

  Future<List<B2BOrderModel>> fetchMyOrders(String shopId) async {
    final QueryOptions options = QueryOptions(
      document: gql(getOrdersQuery),
      variables: {'shopId': shopId},
      fetchPolicy: FetchPolicy.networkOnly, 
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List rawData = result.data?['getB2bOrders'] ?? [];
    return rawData.map((data) => B2BOrderModel.fromJson(data)).toList();
  }
}
