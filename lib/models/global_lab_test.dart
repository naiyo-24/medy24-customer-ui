class GlobalLabTest {
  final String testId;
  final String testName;
  final String category;
  final String description;
  final bool isProfile;
  final int numberOfParameters;
  final String sampleType;
  final String searchTags;
  final bool fastingRequired;
  final int fastingHours;
  final String preTestInfo;

  GlobalLabTest({
    required this.testId,
    required this.testName,
    required this.category,
    required this.description,
    required this.isProfile,
    required this.numberOfParameters,
    required this.sampleType,
    required this.searchTags,
    required this.fastingRequired,
    required this.fastingHours,
    required this.preTestInfo,
  });

  factory GlobalLabTest.fromJson(Map<String, dynamic> json) {
    return GlobalLabTest(
      testId: json['testId'] ?? '',
      testName: json['testName'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      isProfile: json['isProfile'] ?? false,
      numberOfParameters: json['numberOfParameters'] ?? 0,
      sampleType: json['sampleType'] ?? '',
      searchTags: json['searchTags'] ?? '',
      fastingRequired: json['fastingRequired'] ?? false,
      fastingHours: json['fastingHours'] ?? 0,
      preTestInfo: json['preTestInfo'] ?? '',
    );
  }
}
