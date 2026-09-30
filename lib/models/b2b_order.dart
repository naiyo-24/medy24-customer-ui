class B2BOrderItemModel {
  final String medicineId;
  final String batchNumber;
  final int qtyBoxes;
  final double ptr;

  B2BOrderItemModel({
    required this.medicineId,
    required this.batchNumber,
    required this.qtyBoxes,
    required this.ptr,
  });

  factory B2BOrderItemModel.fromJson(Map<String, dynamic> json) {
    return B2BOrderItemModel(
      medicineId: json['medicineId'] ?? '',
      batchNumber: json['batchNumber'] ?? '',
      qtyBoxes: json['qtyBoxes'] ?? 0,
      ptr: (json['ptr'] ?? 0).toDouble(),
    );
  }
}

class B2BOrderModel {
  final String poId;
  final double subtotal;
  final double totalInvoiceAmount;
  final String poStatus;
  final String paymentTerms;
  final String createdAt;
  final List<B2BOrderItemModel> items;
  final String distributorName;

  B2BOrderModel({
    required this.poId,
    required this.subtotal,
    required this.totalInvoiceAmount,
    required this.poStatus,
    required this.paymentTerms,
    required this.createdAt,
    required this.items,
    required this.distributorName,
  });

  factory B2BOrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    return B2BOrderModel(
      poId: json['poId'] ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      totalInvoiceAmount: (json['totalInvoiceAmount'] ?? 0).toDouble(),
      poStatus: json['poStatus'] ?? 'placed',
      paymentTerms: json['paymentTerms'] ?? '',
      createdAt: json['createdAt'] ?? '',
      distributorName: json['distributor']?['companyName'] ?? 'Distributor',
      items: itemsList.map((i) => B2BOrderItemModel.fromJson(i)).toList(),
    );
  }
}
