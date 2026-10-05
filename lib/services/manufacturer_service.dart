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
      print('Manufacturer fetch failed (expected if backend route missing). Returning dummy data.');
      return dummyManufacturers;
    }
  }

  Future<List<ManufacturerMedicineModel>> fetchManufacturerCatalog(String manufacturerId) async {
    try {
      final response = await _dio.get(ApiUrl.getManufacturerCatalog(manufacturerId));
      if (response.statusCode == 200) {
        final List data = response.data is List ? response.data : (response.data['data'] ?? []);
        return data.map((e) => ManufacturerMedicineModel.fromJson(e)).toList();
      }
      throw Exception('Failed to load catalog');
    } catch (e) {
      // NOTE: Fallback to dummy data until backend is built.
      print('Catalog fetch failed for $manufacturerId. Returning dummy data.');
      return dummyManufacturerMedicines;
    }
  }
}
