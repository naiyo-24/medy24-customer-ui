class CoreLabTestModel {
  final String coreTestId;
  final String testName;
  final String testCategory;
  final String sampleType;
  final String? description;
  final List<dynamic> parameters;
  final List<dynamic> precautions;
  final String? testPhotoUrl;

  CoreLabTestModel({
    required this.coreTestId,
    required this.testName,
    required this.testCategory,
    required this.sampleType,
    this.description,
    required this.parameters,
    required this.precautions,
    this.testPhotoUrl,
  });

  factory CoreLabTestModel.fromJson(Map<String, dynamic> json) {
    return CoreLabTestModel(
      coreTestId: json['core_test_id'] ?? '',
      testName: json['test_name'] ?? '',
      testCategory: json['test_category'] ?? '',
      sampleType: json['sample_type'] ?? '',
      description: json['description'],
      parameters: json['parameters'] ?? [],
      precautions: json['precautions'] ?? [],
      testPhotoUrl: json['test_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'core_test_id': coreTestId,
      'test_name': testName,
      'test_category': testCategory,
      'sample_type': sampleType,
      'description': description,
      'parameters': parameters,
      'precautions': precautions,
      'test_photo_url': testPhotoUrl,
    };
  }
}

class LabTestInventoryModel {
  final String testId;
  final String labId;
  final String coreTestId;
  final String sampleCollectionTime;
  final String reportDeliveryTime;
  final double price;
  final double discountPercent;
  final double marketPrice;
  final List<dynamic> reviews;
  final CoreLabTestModel? coreTestDetails;

  LabTestInventoryModel({
    required this.testId,
    required this.labId,
    required this.coreTestId,
    required this.sampleCollectionTime,
    required this.reportDeliveryTime,
    required this.price,
    required this.discountPercent,
    required this.marketPrice,
    required this.reviews,
    this.coreTestDetails,
  });

  bool get hasDiscount => discountPercent > 0 && discountAmount > 0;

  double get discountAmount {
    final savings = price - marketPrice;
    return savings > 0 ? savings : 0;
  }

  factory LabTestInventoryModel.fromJson(Map<String, dynamic> json) {
    return LabTestInventoryModel(
      testId: json['test_id'] ?? '',
      labId: json['lab_id'] ?? '',
      coreTestId: json['core_test_id'] ?? '',
      sampleCollectionTime: json['sample_collection_time'] ?? '',
      reportDeliveryTime: json['report_delivery_time'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPercent: (json['discount_percent'] ?? 0).toDouble(),
      marketPrice: (json['market_price'] ?? 0).toDouble(),
      reviews: json['reviews'] ?? [],
      coreTestDetails: json['core_test_details'] != null
          ? CoreLabTestModel.fromJson(json['core_test_details'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'test_id': testId,
      'lab_id': labId,
      'core_test_id': coreTestId,
      'sample_collection_time': sampleCollectionTime,
      'report_delivery_time': reportDeliveryTime,
      'price': price,
      'discount_percent': discountPercent,
      'market_price': marketPrice,
      'reviews': reviews,
      'core_test_details': coreTestDetails?.toJson(),
    };
  }
}

class TestPackageModel {
  final String packageId;
  final String labId;
  final String packageName;
  final String? packageDescription;
  final String packageSampleCollectionTime;
  final String packageReportDeliveryTime;
  final double packageMarketPrice;
  final double discountPercentage;
  final double packageFinalPrice;
  final List<LabTestInventoryModel> testDetails;

  TestPackageModel({
    required this.packageId,
    required this.labId,
    required this.packageName,
    this.packageDescription,
    required this.packageSampleCollectionTime,
    required this.packageReportDeliveryTime,
    required this.packageMarketPrice,
    required this.discountPercentage,
    required this.packageFinalPrice,
    required this.testDetails,
  });

  bool get hasDiscount {
    final savings = packageMarketPrice - packageFinalPrice;
    return discountPercentage > 0 && savings > 0;
  }

  double get discountAmount {
    final savings = packageMarketPrice - packageFinalPrice;
    return savings > 0 ? savings : 0;
  }

  factory TestPackageModel.fromJson(Map<String, dynamic> json) {
    var testList = json['test_details'] as List? ?? [];
    List<LabTestInventoryModel> tests = testList.map((t) {
      // Handle the enriched fields mapping to LabTestInventoryModel
      return LabTestInventoryModel(
        testId: t['test_id'] ?? '',
        labId: json['lab_id'] ?? '', // Inherit lab_id from package
        coreTestId: t['core_test_id'] ?? '',
        sampleCollectionTime: t['sample_collection_time'] ?? '',
        reportDeliveryTime: t['report_delivery_time'] ?? '',
        price: (t['price'] ?? 0).toDouble(),
        discountPercent: 0, // Not provided per test in package
        marketPrice: (t['price'] ?? 0).toDouble(),
        reviews: [],
        coreTestDetails: t['core_test_details'] != null 
            ? CoreLabTestModel.fromJson(t['core_test_details'])
            : null,
      );
    }).toList();

    return TestPackageModel(
      packageId: json['package_id'] ?? '',
      labId: json['lab_id'] ?? '',
      packageName: json['package_name'] ?? '',
      packageDescription: json['package_description'],
      packageSampleCollectionTime: json['package_sample_collection_time'] ?? '',
      packageReportDeliveryTime: json['package_report_delivery_time'] ?? '',
      packageMarketPrice: (json['package_market_price'] ?? 0).toDouble(),
      discountPercentage: (json['discount_percentage'] ?? 0).toDouble(),
      packageFinalPrice: (json['package_final_price'] ?? 0).toDouble(),
      testDetails: tests,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
      'lab_id': labId,
      'package_name': packageName,
      'package_description': packageDescription,
      'package_sample_collection_time': packageSampleCollectionTime,
      'package_report_delivery_time': packageReportDeliveryTime,
      'package_market_price': packageMarketPrice,
      'discount_percentage': discountPercentage,
      'package_final_price': packageFinalPrice,
      'test_details': testDetails.map((t) => t.toJson()).toList(),
    };
  }
}
