enum BookingItemType { labTest, package }

class BookingPatientDetails {
  final String fullName;
  final String phoneNumber;
  final String gender;
  final int age;
  final String relation;

  const BookingPatientDetails({
    required this.fullName,
    required this.phoneNumber,
    required this.gender,
    required this.age,
    required this.relation,
  });

  BookingPatientDetails copyWith({
    String? fullName,
    String? phoneNumber,
    String? gender,
    int? age,
    String? relation,
  }) {
    return BookingPatientDetails(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      relation: relation ?? this.relation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'gender': gender,
      'age': age,
      'relation': relation,
    };
  }
}

class BookingCollectionAddress {
  final String addressLine1;
  final String streetAddress;
  final double? latitude;
  final double? longitude;
  final int? savedAddressId;

  const BookingCollectionAddress({
    required this.addressLine1,
    required this.streetAddress,
    this.latitude,
    this.longitude,
    this.savedAddressId,
  });

  String get displayAddress => '$addressLine1, $streetAddress';

  BookingCollectionAddress copyWith({
    String? addressLine1,
    String? streetAddress,
    double? latitude,
    double? longitude,
    int? savedAddressId,
  }) {
    return BookingCollectionAddress(
      addressLine1: addressLine1 ?? this.addressLine1,
      streetAddress: streetAddress ?? this.streetAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      savedAddressId: savedAddressId ?? this.savedAddressId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_1': addressLine1,
      'street_address': streetAddress,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (savedAddressId != null) 'saved_address_id': savedAddressId,
    };
  }
}

class BookingPriceSummary {
  final double subtotal;
  final double discount;
  final double platformFee;
  final double taxCharges;
  final double totalAmount;

  const BookingPriceSummary({
    required this.subtotal,
    required this.discount,
    required this.platformFee,
    required this.taxCharges,
    required this.totalAmount,
  });

  double get itemTotal => subtotal - discount;
}

class TestPackageBooking {
  final BookingItemType itemType;
  final String itemId;
  final String labId;
  final String itemName;
  final String? itemSubtitle;
  final bool isBookingForSelf;
  final BookingPatientDetails patient;
  final BookingCollectionAddress? collectionAddress;
  final BookingPriceSummary priceSummary;
  final String? customerId;

  const TestPackageBooking({
    required this.itemType,
    required this.itemId,
    required this.labId,
    required this.itemName,
    this.itemSubtitle,
    required this.isBookingForSelf,
    required this.patient,
    this.collectionAddress,
    required this.priceSummary,
    this.customerId,
  });

  TestPackageBooking copyWith({
    BookingItemType? itemType,
    String? itemId,
    String? labId,
    String? itemName,
    String? itemSubtitle,
    bool? isBookingForSelf,
    BookingPatientDetails? patient,
    BookingCollectionAddress? collectionAddress,
    BookingPriceSummary? priceSummary,
    String? customerId,
  }) {
    return TestPackageBooking(
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      labId: labId ?? this.labId,
      itemName: itemName ?? this.itemName,
      itemSubtitle: itemSubtitle ?? this.itemSubtitle,
      isBookingForSelf: isBookingForSelf ?? this.isBookingForSelf,
      patient: patient ?? this.patient,
      collectionAddress: collectionAddress ?? this.collectionAddress,
      priceSummary: priceSummary ?? this.priceSummary,
      customerId: customerId ?? this.customerId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_type': itemType == BookingItemType.labTest ? 'lab_test' : 'package',
      'item_id': itemId,
      'lab_id': labId,
      'item_name': itemName,
      'is_booking_for_self': isBookingForSelf,
      'patient': patient.toJson(),
      if (collectionAddress != null)
        'collection_address': collectionAddress!.toJson(),
      'subtotal': priceSummary.subtotal,
      'discount': priceSummary.discount,
      'platform_fee': priceSummary.platformFee,
      'tax_charges': priceSummary.taxCharges,
      'total_amount': priceSummary.totalAmount,
      if (customerId != null) 'customer_id': customerId,
    };
  }
}
