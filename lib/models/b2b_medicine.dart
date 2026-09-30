class DistributorStockModel {
  final String inventoryId;
  final String distributorId;
  final String companyName;
  final String? batchNumber;
  final double ptr;
  final double mrp;
  final int availableStockBoxes;
  final int moq;

  DistributorStockModel({
    required this.inventoryId,
    required this.distributorId,
    required this.companyName,
    this.batchNumber,
    required this.ptr,
    required this.mrp,
    required this.availableStockBoxes,
    required this.moq,
  });

  factory DistributorStockModel.fromJson(Map<String, dynamic> json) {
    return DistributorStockModel(
      inventoryId: json['inventoryId'] ?? '',
      distributorId: json['distributorId'] ?? '',
      companyName: json['companyName'] ?? '',
      batchNumber: json['batchNumber'],
      ptr: (json['ptr'] ?? 0).toDouble(),
      mrp: (json['mrp'] ?? 0).toDouble(),
      availableStockBoxes: json['availableStockBoxes'] ?? 0,
      moq: json['moq'] ?? 1,
    );
  }
}

class B2BMedicineModel {
  final String medicineId;
  final String medicineName;
  final String packSize;
  final String? manufacturer;
  final List<DistributorStockModel> availableSellers;

  B2BMedicineModel({
    required this.medicineId,
    required this.medicineName,
    required this.packSize,
    this.manufacturer,
    required this.availableSellers,
  });

  factory B2BMedicineModel.fromJson(Map<String, dynamic> json) {
    var sellersList = json['availableSellers'] as List? ?? [];
    return B2BMedicineModel(
      medicineId: json['medicineId'] ?? '',
      medicineName: json['medicineName'] ?? '',
      packSize: json['packSize'] ?? '',
      manufacturer: json['manufacturer'],
      availableSellers: sellersList
          .map((seller) => DistributorStockModel.fromJson(seller))
          .toList(),
    );
  }
}
