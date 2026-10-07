import re

with open("lib/services/manufacturer_service.dart", "r") as f:
    content = f.read()

new_method = """  Future<List<ManufacturerMedicineModel>> fetchManufacturerCatalog(String manufacturerId, {String? searchQuery}) async {
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
        ApiUrl.baseUrl + '/graphql',
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
      print('GraphQL Catalog fetch failed for $manufacturerId. Returning dummy data. Error: $e');
      // If we fall back to dummy data, do a local search filter
      var list = dummyManufacturerMedicines;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        list = list.where((m) => m.name.toLowerCase().contains(query)).toList();
      }
      return list;
    }
  }"""

# Replace the existing method
content = re.sub(
    r"Future<List<ManufacturerMedicineModel>> fetchManufacturerCatalog\(String manufacturerId\) async \{.*?\n  \}",
    new_method,
    content,
    flags=re.DOTALL
)

with open("lib/services/manufacturer_service.dart", "w") as f:
    f.write(content)
print("Updated manufacturer_service.dart")
