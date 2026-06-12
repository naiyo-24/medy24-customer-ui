import 'dart:convert';

class MedicineModel {
  final String? medicineId;
  final String? medicineName;
  final String? medicineCategory;
  final String? medicineQuantity;
  final double? mrp;
  final double? discountPercent;
  final double? finalPrice;
  final String? medicineDescription;
  final String? medicineComposition;
  final List<dynamic>? precautions;
  final String? prescriptionRequired;
  final String? medicinePhoto;
  final bool? isActive;

  MedicineModel({
    this.medicineId,
    this.medicineName,
    this.medicineCategory,
    this.medicineQuantity,
    this.mrp,
    this.discountPercent,
    this.finalPrice,
    this.medicineDescription,
    this.medicineComposition,
    this.precautions,
    this.prescriptionRequired,
    this.medicinePhoto,
    this.isActive,
  });

  MedicineModel copyWith({
    String? medicineId,
    String? medicineName,
    String? medicineCategory,
    String? medicineQuantity,
    double? mrp,
    double? discountPercent,
    double? finalPrice,
    String? medicineDescription,
    String? medicineComposition,
    List<dynamic>? precautions,
    String? prescriptionRequired,
    String? medicinePhoto,
    bool? isActive,
  }) {
    return MedicineModel(
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      medicineCategory: medicineCategory ?? this.medicineCategory,
      medicineQuantity: medicineQuantity ?? this.medicineQuantity,
      mrp: mrp ?? this.mrp,
      discountPercent: discountPercent ?? this.discountPercent,
      finalPrice: finalPrice ?? this.finalPrice,
      medicineDescription: medicineDescription ?? this.medicineDescription,
      medicineComposition: medicineComposition ?? this.medicineComposition,
      precautions: precautions ?? this.precautions,
      prescriptionRequired: prescriptionRequired ?? this.prescriptionRequired,
      medicinePhoto: medicinePhoto ?? this.medicinePhoto,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicine_id': medicineId,
      'medicine_name': medicineName,
      'medicine_category': medicineCategory,
      'medicine_quantity': medicineQuantity,
      'mrp': mrp,
      'discount_percent': discountPercent,
      'final_selling_price': finalPrice,
      'medicine_description': medicineDescription,
      'medicine_composition': medicineComposition,
      'precautions': precautions,
      'prescription_required': prescriptionRequired,
      'medicine_photo': medicinePhoto,
      'is_active': isActive,
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      medicineId: map['medicine_id'],
      medicineName: map['medicine_name'],
      medicineCategory: map['medicine_category'],
      medicineQuantity: map['medicine_quantity'],
      mrp: (map['mrp'] as num?)?.toDouble(),
      discountPercent: (map['discount_percent'] as num?)?.toDouble(),
      finalPrice: (map['final_selling_price'] as num?)?.toDouble(),
      medicineDescription: map['medicine_description'],
      medicineComposition: map['medicine_composition'],
      precautions: _parsePrecautions(map['precautions']),
      prescriptionRequired: map['prescription_required']?.toString(),
      medicinePhoto: map['medicine_photo'],
      isActive: map['is_active'],
    );
  }

  static List<dynamic>? _parsePrecautions(dynamic data) {
    if (data == null) return null;
    if (data is String) {
      try {
        data = json.decode(data);
      } catch (_) {
        return [data];
      }
    }
    if (data is List) return data;
    if (data is Map) {
      return data.entries.map((e) => '\${e.key}: \${e.value}').toList();
    }
    return [data.toString()];
  }

  String toJson() => json.encode(toMap());

  factory MedicineModel.fromJson(String source) =>
      MedicineModel.fromMap(json.decode(source));
}
