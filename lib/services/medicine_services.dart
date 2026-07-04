import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_url.dart';

class MedicineService {
  final Dio _dio = Dio();

  MedicineService() {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  static const String _searchMedicinesQuery = """
    query SearchMedicines(\$query: String, \$category: String, \$limit: Int!, \$offset: Int!) {
      searchMedicines(query: \$query, category: \$category, limit: \$limit, offset: \$offset) {
        medicine_id: medicineId
        medicine_name: medicineName
        medicine_photo: medicinePhoto
        mrp
        final_selling_price: finalSellingPrice
        discount_percent: discountPercent
      }
    }
  """;

  static const String _getMedicineByIdQuery = """
    query GetMedicineById(\$id: String!) {
      getMedicineById(medicineId: \$id) {
        medicine_id: medicineId
        medicine_name: medicineName
        manufacturer
        pack_form: packForm
        pack_size: packSize
        medicine_category: medicineCategory
        medicine_photo: medicinePhoto
        medicine_description: medicineDescription
        medicine_composition: medicineComposition
        precautions
        mrp
        discount_percent: discountPercent
        final_selling_price: finalSellingPrice
        prescription_required: prescriptionRequired
      }
    }
  """;

  Future<Response> getAllMedicines({int page = 1, int limit = 20}) async {
    try {
      final offset = (page - 1) * limit;
      return await _dio.post(
        ApiUrl.graphql,
        data: {
          'query': _searchMedicinesQuery,
          'variables': {
            'limit': limit,
            'offset': offset,
          },
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getMedicineById(String id) async {
    try {
      return await _dio.post(
        ApiUrl.graphql,
        data: {
          'query': _getMedicineByIdQuery,
          'variables': {
            'id': id,
          },
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> searchMedicines({
    String? searchTerm,
    List<String>? priceRange,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final offset = (page - 1) * limit;
      final Map<String, dynamic> variables = {
        'limit': limit,
        'offset': offset,
      };
      
      if (searchTerm != null && searchTerm.isNotEmpty) {
        variables['query'] = searchTerm;
      }
      if (category != null && category.isNotEmpty) {
        variables['category'] = category;
      }
      // Note: priceRange is currently not supported by the GraphQL schema

      return await _dio.post(
        ApiUrl.graphql,
        data: {
          'query': _searchMedicinesQuery,
          'variables': variables,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
