class FeaturedPackage {
  final String testId;
  final String testName;
  final int numberOfParameters;
  final double startingPrice;
  final String category;

  FeaturedPackage({
    required this.testId,
    required this.testName,
    required this.numberOfParameters,
    required this.startingPrice,
    required this.category,
  });

  factory FeaturedPackage.fromJson(Map<String, dynamic> json) {
    return FeaturedPackage(
      testId: json['testId'] ?? '',
      testName: json['testName'] ?? '',
      numberOfParameters: json['numberOfParameters'] ?? 0,
      startingPrice: (json['startingPrice'] ?? 0).toDouble(),
      category: json['category'] ?? '',
    );
  }
}
