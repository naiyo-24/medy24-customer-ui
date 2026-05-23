import 'medicine.dart';

class CartItem {
  final MedicineModel medicine;
  final int quantity;

  CartItem({
    required this.medicine,
    required this.quantity,
  });

  CartItem copyWith({
    MedicineModel? medicine,
    int? quantity,
  }) {
    return CartItem(
      medicine: medicine ?? this.medicine,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      medicine: MedicineModel(
        medicineId: json['medicine_id']?.toString(),
        medicineName: json['medicine_name']?.toString(),
        finalPrice: json['price_per_unit'] != null ? double.tryParse(json['price_per_unit'].toString()) : null,
        mrp: json['price_per_unit'] != null ? double.tryParse(json['price_per_unit'].toString()) : null, // API only gives price_per_unit
        medicinePhoto: json['medicine_photo']?.toString(),
      ),
      quantity: json['quantity'] ?? 1,
    );
  }
}

class CartSummary {
  final double totalItemAmount;
  final double totalDiscount;
  final double platformCharges;
  final double deliveryFees;
  final double taxes;
  final double totalAmountToBePaid;
  final double totalSaved;

  CartSummary({
    required this.totalItemAmount,
    required this.totalDiscount,
    required this.platformCharges,
    required this.deliveryFees,
    required this.taxes,
    required this.totalAmountToBePaid,
    required this.totalSaved,
  });
}
