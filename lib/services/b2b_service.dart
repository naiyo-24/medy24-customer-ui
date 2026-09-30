import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/b2b_medicine.dart';

class B2BService {
  final GraphQLClient client;

  B2BService(this.client);

  static const String searchMedicinesQuery = r'''
    query SearchWholesale($query: String!, $lat: Float!, $lng: Float!) {
      searchB2bMedicines(query: $query, lat: $lat, lng: $lng) {
        medicineId
        medicineName
        packSize
        manufacturer
        availableSellers {
          inventoryId
          distributorId
          companyName
          batchNumber
          ptr
          mrp
          availableStockBoxes
          moq
        }
      }
    }
  ''';

  Future<List<B2BMedicineModel>> searchB2BMedicines(String query, double lat, double lng) async {
    final QueryOptions options = QueryOptions(
      document: gql(searchMedicinesQuery),
      variables: {
        'query': query,
        'lat': lat,
        'lng': lng,
      },
      fetchPolicy: FetchPolicy.networkOnly, // Always fetch fresh wholesale rates
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List rawData = result.data?['searchB2bMedicines'] ?? [];
    return rawData.map((data) => B2BMedicineModel.fromJson(data)).toList();
  }
}
