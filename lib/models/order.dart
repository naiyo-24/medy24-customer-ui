import 'dart:convert';
import 'cart.dart';

class OrderModel {
  final String? orderId;
  final String? customerId;
  final String? shopId;
  final String? orderType;
  final String? prescriptionUrl;
  final List<CartItem> items;
  final String? receiverName;
  final String? receiverPhone;
  final Map<String, dynamic>? deliveryAddress;
  final double? itemTotal;
  final double? platformFee;
  final double? deliveryFee;
  final double? taxes;
  final double? totalBillAmount;
  final String? paymentMode;
  final String? paymentStatus;
  final String? orderStatus;
  final String? riderName;
  final String? riderPhone;
  final String? vehicleNumber;
  final String? vehicleModel;
  final String? transactionId;
  final DateTime? acceptedAt;
  final DateTime? deliveredAt;
  final DateTime? createdAt;

  OrderModel({
    this.orderId,
    this.customerId,
    this.shopId,
    this.orderType,
    this.prescriptionUrl,
    this.items = const [],
    this.receiverName,
    this.receiverPhone,
    this.deliveryAddress,
    this.itemTotal,
    this.platformFee,
    this.deliveryFee,
    this.taxes,
    this.totalBillAmount,
    this.paymentMode,
    this.paymentStatus,
    this.orderStatus,
    this.riderName,
    this.riderPhone,
    this.vehicleNumber,
    this.vehicleModel,
    this.transactionId,
    this.acceptedAt,
    this.deliveredAt,
    this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['order_id']?.toString(),
      customerId: map['customer_id']?.toString(),
      shopId: map['shop_id']?.toString(),
      orderType: map['order_type']?.toString(),
      prescriptionUrl: map['prescription_url']?.toString(),
      items: map['items'] != null
          ? List<CartItem>.from(map['items']?.map((x) => CartItem.fromJson(x)))
          : [],
      receiverName: map['receiver_name']?.toString(),
      receiverPhone: map['receiver_phone']?.toString(),
      deliveryAddress: map['delivery_address'] != null && map['delivery_address'] is Map
          ? Map<String, dynamic>.from(map['delivery_address'])
          : null,
      itemTotal: map['item_total'] != null ? double.tryParse(map['item_total'].toString()) : null,
      platformFee: map['platform_fee'] != null ? double.tryParse(map['platform_fee'].toString()) : null,
      deliveryFee: map['delivery_fee'] != null ? double.tryParse(map['delivery_fee'].toString()) : null,
      taxes: map['taxes'] != null ? double.tryParse(map['taxes'].toString()) : null,
      totalBillAmount: map['total_bill_amount'] != null ? double.tryParse(map['total_bill_amount'].toString()) : null,
      paymentMode: map['payment_mode']?.toString(),
      paymentStatus: map['payment_status']?.toString(),
      orderStatus: map['order_status']?.toString(),
      riderName: map['rider_name']?.toString(),
      riderPhone: map['rider_phone']?.toString(),
      vehicleNumber: map['vehicle_number']?.toString(),
      vehicleModel: map['vehicle_model']?.toString(),
      transactionId: map['transaction_id']?.toString(),
      acceptedAt: map['accepted_at'] != null ? DateTime.tryParse(map['accepted_at']) : null,
      deliveredAt: map['delivered_at'] != null ? DateTime.tryParse(map['delivered_at']) : null,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at']) : null,
    );
  }

  factory OrderModel.fromJson(String source) => OrderModel.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'customer_id': customerId,
      'shop_id': shopId,
      'order_type': orderType,
      'prescription_url': prescriptionUrl,
      // 'items': items.map((x) => x.toMap()).toList(), // cart item to map not strictly needed for UI models
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'delivery_address': deliveryAddress,
      'item_total': itemTotal,
      'platform_fee': platformFee,
      'delivery_fee': deliveryFee,
      'taxes': taxes,
      'total_bill_amount': totalBillAmount,
      'payment_mode': paymentMode,
      'payment_status': paymentStatus,
      'order_status': orderStatus,
      'rider_name': riderName,
      'rider_phone': riderPhone,
      'vehicle_number': vehicleNumber,
      'vehicle_model': vehicleModel,
      'transaction_id': transactionId,
      'accepted_at': acceptedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());
}
