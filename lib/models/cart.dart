import 'medicine.dart';

class CartItem {
  final MedicineModel medicine;
  final int quantity;

  CartItem({required this.medicine, required this.quantity});

  CartItem copyWith({MedicineModel? medicine, int? quantity}) {
    return CartItem(
      medicine: medicine ?? this.medicine,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Check both REST snake_case and GraphQL camelCase fields
    final priceVal = json['price'] ?? json['price_per_unit'];
    final parsedPrice = priceVal != null
        ? double.tryParse(priceVal.toString())
        : null;

    return CartItem(
      medicine: MedicineModel(
        medicineId: (json['medicineId'] ?? json['medicine_id'])?.toString(),
        medicineName: (json['medicineName'] ?? json['medicine_name'] ?? json['name'])?.toString(),
        finalPrice: parsedPrice,
        mrp: parsedPrice, // GraphQL gives price
        medicinePhoto: (json['medicinePhoto'] ?? json['medicine_photo'])?.toString(),
        medicineQuantity: (json['packSize'] ?? json['pack_size'])?.toString(),
      ),
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'medicine_id': medicine.medicineId,
      'medicine_name': medicine.medicineName,
      'price_per_unit': medicine.finalPrice ?? medicine.mrp,
      'pack_size': medicine.medicineQuantity,
      'medicine_photo': medicine.medicinePhoto,
      'quantity': quantity,
    };
  }
}

class CartSummary {
  final double totalItemAmount;
  final double totalDiscount;
  final double platformCharges;
  final double deliveryFees;
  final double taxes;
  final double deliveryTip;
  final double totalAmountToBePaid;
  final double totalSaved;
  final double orderValueDiscount;

  CartSummary({
    required this.totalItemAmount,
    required this.totalDiscount,
    required this.orderValueDiscount,
    required this.platformCharges,
    required this.deliveryFees,
    required this.taxes,
    required this.deliveryTip,
    required this.totalAmountToBePaid,
    required this.totalSaved,
  });
}
