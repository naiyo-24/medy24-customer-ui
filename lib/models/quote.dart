import 'dart:convert';

class QuoteModel {
  final String quoteId;
  final String orderId;
  final String shopId;
  final String? shopName;
  final String? shopPhone;
  final String? shopAddress;
  final List<dynamic> items;
  final double itemTotal;
  final double platformFee;
  final double deliveryFee;
  final double deliveryTip;
  final double taxes;
  final double totalBillAmount;
  final String status;
  final DateTime? createdAt;

  QuoteModel({
    required this.quoteId,
    required this.orderId,
    required this.shopId,
    this.shopName,
    this.shopPhone,
    this.shopAddress,
    required this.items,
    required this.itemTotal,
    required this.platformFee,
    required this.deliveryFee,
    required this.deliveryTip,
    required this.taxes,
    required this.totalBillAmount,
    required this.status,
    this.createdAt,
  });

  factory QuoteModel.fromMap(Map<String, dynamic> map) {
    return QuoteModel(
      quoteId: map['quote_id'] ?? '',
      orderId: map['order_id'] ?? '',
      shopId: map['shop_id'] ?? '',
      shopName: map['shop_name'],
      shopPhone: map['shop_phone'],
      shopAddress: map['shop_address'],
      items: List<dynamic>.from(map['items'] ?? []),
      itemTotal: (map['item_total'] ?? 0.0).toDouble(),
      platformFee: (map['platform_fee'] ?? 0.0).toDouble(),
      deliveryFee: (map['delivery_fee'] ?? 0.0).toDouble(),
      deliveryTip: (map['delivery_tip'] ?? 0.0).toDouble(),
      taxes: (map['taxes'] ?? 0.0).toDouble(),
      totalBillAmount: (map['total_bill_amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending_approval',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quote_id': quoteId,
      'order_id': orderId,
      'shop_id': shopId,
      'shop_name': shopName,
      'shop_phone': shopPhone,
      'shop_address': shopAddress,
      'items': items,
      'item_total': itemTotal,
      'platform_fee': platformFee,
      'delivery_fee': deliveryFee,
      'delivery_tip': deliveryTip,
      'taxes': taxes,
      'total_bill_amount': totalBillAmount,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory QuoteModel.fromJson(String source) => QuoteModel.fromMap(json.decode(source));
}
