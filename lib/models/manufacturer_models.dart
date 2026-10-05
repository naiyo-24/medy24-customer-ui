class ManufacturerModel {
  final String id;
  final String name;
  final String logoUrl;
  final String minimumOrderAmount;
  
  ManufacturerModel({
    required this.id, 
    required this.name, 
    required this.logoUrl, 
    required this.minimumOrderAmount,
  });

  factory ManufacturerModel.fromJson(Map<String, dynamic> json) {
    return ManufacturerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString() ?? '',
      minimumOrderAmount: json['minimumOrderAmount']?.toString() ?? '',
    );
  }
}

class ManufacturerMedicineModel {
  final String id;
  final String name;
  final String packSize;
  final double ptr;
  final double mrp;
  final int moq; 
  final String batchNumber;
  
  ManufacturerMedicineModel({
    required this.id, 
    required this.name, 
    required this.packSize, 
    required this.ptr, 
    required this.mrp, 
    required this.moq,
    required this.batchNumber,
  });

  factory ManufacturerMedicineModel.fromJson(Map<String, dynamic> json) {
    return ManufacturerMedicineModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      packSize: json['packSize']?.toString() ?? '',
      ptr: (json['ptr'] as num?)?.toDouble() ?? 0.0,
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0.0,
      moq: json['moq'] as int? ?? 100,
      batchNumber: json['batchNumber']?.toString() ?? '',
    );
  }
}

// DUMMY DATA FOR UI
final List<ManufacturerModel> dummyManufacturers = [
  ManufacturerModel(
    id: 'm1',
    name: 'Cipla Limited',
    logoUrl: 'https://via.placeholder.com/150/0000FF/808080?Text=Cipla',
    minimumOrderAmount: '₹50,000',
  ),
  ManufacturerModel(
    id: 'm2',
    name: 'Sun Pharmaceutical',
    logoUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?Text=Sun+Pharma',
    minimumOrderAmount: '₹1,00,000',
  ),
  ManufacturerModel(
    id: 'm3',
    name: 'Dr. Reddy\'s Laboratories',
    logoUrl: 'https://via.placeholder.com/150/008000/FFFFFF?Text=Dr.+Reddys',
    minimumOrderAmount: '₹75,000',
  ),
];

final List<ManufacturerMedicineModel> dummyManufacturerMedicines = [
  ManufacturerMedicineModel(
    id: 'med1',
    name: 'Dolo 650 Tablet',
    packSize: '15 Tablets / Strip',
    ptr: 22.50,
    mrp: 30.00,
    moq: 1000, 
    batchNumber: 'B-29001',
  ),
  ManufacturerMedicineModel(
    id: 'med2',
    name: 'Azithral 500 Tablet',
    packSize: '5 Tablets / Strip',
    ptr: 95.00,
    mrp: 120.00,
    moq: 500,
    batchNumber: 'B-29002',
  ),
  ManufacturerMedicineModel(
    id: 'med3',
    name: 'Pantocid 40 Tablet',
    packSize: '15 Tablets / Strip',
    ptr: 110.00,
    mrp: 145.00,
    moq: 500,
    batchNumber: 'B-29003',
  ),
];
