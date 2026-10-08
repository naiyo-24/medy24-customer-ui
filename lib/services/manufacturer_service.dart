import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/manufacturer_models.dart';
import 'api_url.dart';

class ManufacturerService {
  final Dio _dio;

  ManufacturerService(this._dio);

  Future<List<ManufacturerModel>> fetchManufacturers() async {
    try {
      final response = await _dio.get(ApiUrl.getManufacturersAll);
      if (response.statusCode == 200) {
        final List data = response.data is List ? response.data : (response.data['data'] ?? []);
        return data.map((e) => ManufacturerModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load manufacturers');
    } catch (e) {
      // NOTE: Fallback to dummy data until backend is built.
      debugPrint('Manufacturer fetch failed (expected if backend route missing). Returning dummy data.');
      return dummyManufacturers;
    }
  }

    Future<List<ManufacturerMedicineModel>> fetchManufacturerCatalog(String manufacturerId, {String? searchQuery}) async {
    try {
      final query = r'''
        query GetManufacturerCatalog($manufacturerId: String!, $searchQuery: String) {
          getManufacturerCatalog(manufacturerId: $manufacturerId, searchQuery: $searchQuery) {
            inventoryId
            medicineId
            medicineName
            packSize
            batchNumber
            ptd
            mrp
          }
        }
      ''';
      
      final response = await _dio.post(
        '${ApiUrl.baseUrl}/graphql',
        data: {
          'query': query,
          'variables': {
            'manufacturerId': manufacturerId,
            'searchQuery': searchQuery,
          }
        }
      );
      
      if (response.statusCode == 200 && response.data['data'] != null && response.data['data']['getManufacturerCatalog'] != null) {
        final List data = response.data['data']['getManufacturerCatalog'];
        return data.map((e) => ManufacturerMedicineModel(
          id: e['medicineId'],
          name: e['medicineName'],
          packSize: e['packSize'] ?? '',
          ptr: (e['ptd'] as num).toDouble(),
          mrp: (e['mrp'] as num).toDouble(),
          moq: 100, // Hardcoded MOQ for now
          batchNumber: e['batchNumber'] ?? '',
        )).toList();
      }
      throw Exception('GraphQL error or no data');
    } catch (e) {
      debugPrint('GraphQL Catalog fetch failed for $manufacturerId. Returning dummy data. Error: $e');
      // If we fall back to dummy data, do a local search filter
      var list = dummyManufacturerMedicines;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        list = list.where((m) => m.name.toLowerCase().contains(query)).toList();
      }
      return list;
    }
  }
}
