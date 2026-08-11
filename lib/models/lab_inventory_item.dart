class LabInventoryItem {
  final String id;
  final String testId;
  final String testName;
  final String category;
  final double mrp;
  final double discountPercent;
  final double finalPrice;
  final int turnaroundTimeHours;
  final bool homeCollectionAvailable;
  final bool walkInAvailable;

  LabInventoryItem({
    required this.id,
    required this.testId,
    required this.testName,
    required this.category,
    required this.mrp,
    required this.discountPercent,
    required this.finalPrice,
    required this.turnaroundTimeHours,
    required this.homeCollectionAvailable,
    required this.walkInAvailable,
  });

  factory LabInventoryItem.fromJson(Map<String, dynamic> json) {
    return LabInventoryItem(
      id: json['id'] ?? '',
      testId: json['test_id'] ?? json['testId'] ?? '',
      testName: json['test_name'] ?? json['testName'] ?? '',
      category: json['category'] ?? '',
      mrp: (json['mrp'] ?? 0.0).toDouble(),
      discountPercent: (json['discount_percent'] ?? json['discountPercent'] ?? 0.0).toDouble(),
      finalPrice: (json['final_price'] ?? json['finalPrice'] ?? 0.0).toDouble(),
      turnaroundTimeHours: json['turnaround_time_hours'] ?? json['turnaroundTimeHours'] ?? 24,
      homeCollectionAvailable: json['home_collection_available'] ?? json['homeCollectionAvailable'] ?? true,
      walkInAvailable: json['walk_in_available'] ?? json['walkInAvailable'] ?? true,
    );
  }
}
