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
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List rawData = result.data?['searchB2bMedicines'] ?? [];
    return rawData.map((data) => B2BMedicineModel.fromJson(data)).toList();
  }

  static const String nearbyDistributorsQuery = r'''
    query GetNearbyDistributors($lat: Float!, $lng: Float!) {
      getNearbyDistributors(lat: $lat, lng: $lng) {
        distributorId
        companyName
        phone
        address
        distanceKm
      }
    }
  ''';

  Future<List<dynamic>> getNearbyDistributors(double lat, double lng) async {
    final QueryOptions options = QueryOptions(
      document: gql(nearbyDistributorsQuery),
      variables: {
        'lat': lat,
        'lng': lng,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final QueryResult result = await client.query(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    return result.data?['getNearbyDistributors'] ?? [];
  }

  static const String distributorCatalogQuery = r'''
    query GetDistributorCatalog($distributorId: String!) {
      getDistributorCatalog(distributorId: $distributorId) {
        inventoryId
        medicineId
        medicineName
        packSize
        manufacturer
        batchNumber
        ptr
        mrp
        availableStockBoxes
        moq
      }
    }
  ''';

  Future<List<dynamic>> getDistributorCatalog(String distributorId) async {
    final QueryOptions options = QueryOptions(
      document: gql(distributorCatalogQuery),
      variables: {
        'distributorId': distributorId,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    );
    final QueryResult result = await client.query(options);
    if (result.hasException) {
      throw Exception(result.exception.toString());
    }
    return result.data?['getDistributorCatalog'] ?? [];
  }
}
