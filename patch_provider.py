import re

with open("lib/providers/manufacturer_provider.dart", "r") as f:
    content = f.read()

new_provider = """
class CatalogRequest {
  final String manufacturerId;
  final String? searchQuery;
  
  CatalogRequest({required this.manufacturerId, this.searchQuery});
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogRequest &&
          runtimeType == other.runtimeType &&
          manufacturerId == other.manufacturerId &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode => manufacturerId.hashCode ^ (searchQuery?.hashCode ?? 0);
}

final manufacturerCatalogProvider = FutureProvider.family<List<ManufacturerMedicineModel>, CatalogRequest>((ref, request) async {
  final service = ref.watch(manufacturerServiceProvider);
  return service.fetchManufacturerCatalog(request.manufacturerId, searchQuery: request.searchQuery);
});
"""

content = re.sub(
    r"final manufacturerCatalogProvider = FutureProvider\.family<List<ManufacturerMedicineModel>, String>\(\(ref, manufacturerId\) async \{.*?\n\}\);",
    new_provider.strip(),
    content,
    flags=re.DOTALL
)

with open("lib/providers/manufacturer_provider.dart", "w") as f:
    f.write(content)
print("Updated provider")
