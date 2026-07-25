class LabPackage {
  final String labId;
  final String labName;
  final double rating;
  final double totalPrice;
  final bool isFullMatch;
  final int matchCount;
  final List<MatchedTest> matchedTests;
  final List<MissingTest> missingTests;

  LabPackage({
    required this.labId,
    required this.labName,
    required this.rating,
    required this.totalPrice,
    required this.isFullMatch,
    required this.matchCount,
    required this.matchedTests,
    required this.missingTests,
  });

  factory LabPackage.fromJson(Map<String, dynamic> json) {
    return LabPackage(
      labId: json['labId'] ?? '',
      labName: json['labName'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      isFullMatch: json['isFullMatch'] ?? false,
      matchCount: json['matchCount'] ?? 0,
      matchedTests: (json['matchedTests'] as List? ?? [])
          .map((item) => MatchedTest.fromJson(item))
          .toList(),
      missingTests: (json['missingTests'] as List? ?? [])
          .map((item) => MissingTest.fromJson(item))
          .toList(),
    );
  }
}

class MatchedTest {
  final String testId;
  final String testName;
  final double price;

  MatchedTest({
    required this.testId,
    required this.testName,
    required this.price,
  });

  factory MatchedTest.fromJson(Map<String, dynamic> json) {
    return MatchedTest(
      testId: json['testId'] ?? '',
      testName: json['testName'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }
}

class MissingTest {
  final String testId;
  final String testName;

  MissingTest({
    required this.testId,
    required this.testName,
  });

  factory MissingTest.fromJson(Map<String, dynamic> json) {
    return MissingTest(
      testId: json['testId'] ?? '',
      testName: json['testName'] ?? '',
    );
  }
}
