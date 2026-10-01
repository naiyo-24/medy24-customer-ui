class NearbyDistributorModel {
  final String distributorId;
  final String companyName;
  final String? phone;
  final String? address;
  final double distanceKm;

  NearbyDistributorModel({
    required this.distributorId,
    required this.companyName,
    this.phone,
    this.address,
    required this.distanceKm,
  });

  factory NearbyDistributorModel.fromJson(Map<String, dynamic> json) {
    return NearbyDistributorModel(
      distributorId: json['distributorId'] ?? '',
      companyName: json['companyName'] ?? '',
      phone: json['phone'],
      address: json['address'],
      distanceKm: (json['distanceKm'] ?? 0.0).toDouble(),
    );
  }
}

class DistributorCatalogItemModel {
  final String inventoryId;
  final String medicineId;
  final String medicineName;
  final String packSize;
  final String? manufacturer;
  final String? batchNumber;
  final double ptr;
  final double mrp;
  final int availableStockBoxes;
  final int moq;

  DistributorCatalogItemModel({
    required this.inventoryId,
    required this.medicineId,
    required this.medicineName,
    required this.packSize,
    this.manufacturer,
    this.batchNumber,
    required this.ptr,
    required this.mrp,
    required this.availableStockBoxes,
    required this.moq,
  });

  factory DistributorCatalogItemModel.fromJson(Map<String, dynamic> json) {
    return DistributorCatalogItemModel(
      inventoryId: json['inventoryId'] ?? '',
      medicineId: json['medicineId'] ?? '',
      medicineName: json['medicineName'] ?? '',
      packSize: json['packSize'] ?? '',
      manufacturer: json['manufacturer'],
      batchNumber: json['batchNumber'],
      ptr: (json['ptr'] ?? 0).toDouble(),
      mrp: (json['mrp'] ?? 0).toDouble(),
      availableStockBoxes: json['availableStockBoxes'] ?? 0,
      moq: json['moq'] ?? 1,
    );
  }
}
