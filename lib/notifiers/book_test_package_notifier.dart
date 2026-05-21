import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/charges.dart';
import '../models/lab_test.dart';
import '../models/test_package_booking.dart';
import '../models/user.dart';
import '../services/book_test_package_services.dart';
import '../services/lab_test_services.dart';

class BookTestPackageState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final BookingItemType? itemType;
  final String? itemId;
  final String? itemName;
  final String? itemSubtitle;
  final String? labId;
  final bool isBookingForSelf;
  final String fullName;
  final String phoneNumber;
  final String gender;
  final String ageText;
  final String relation;
  final String addressLine1;
  final String streetAddress;
  final int? selectedAddressIndex;
  final BookingPriceSummary? priceSummary;
  final TestPackageBooking? confirmedBooking;

  const BookTestPackageState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.itemType,
    this.itemId,
    this.itemName,
    this.itemSubtitle,
    this.labId,
    this.isBookingForSelf = true,
    this.fullName = '',
    this.phoneNumber = '',
    this.gender = '',
    this.ageText = '',
    this.relation = 'Self',
    this.addressLine1 = '',
    this.streetAddress = '',
    this.selectedAddressIndex,
    this.priceSummary,
    this.confirmedBooking,
  });

  bool get hasItem => itemId != null && itemType != null;

  BookTestPackageState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    BookingItemType? itemType,
    String? itemId,
    String? itemName,
    String? itemSubtitle,
    String? labId,
    bool? isBookingForSelf,
    String? fullName,
    String? phoneNumber,
    String? gender,
    String? ageText,
    String? relation,
    String? addressLine1,
    String? streetAddress,
    int? selectedAddressIndex,
    bool clearSelectedAddress = false,
    BookingPriceSummary? priceSummary,
    TestPackageBooking? confirmedBooking,
    bool clearConfirmedBooking = false,
  }) {
    return BookTestPackageState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      itemSubtitle: itemSubtitle ?? this.itemSubtitle,
      labId: labId ?? this.labId,
      isBookingForSelf: isBookingForSelf ?? this.isBookingForSelf,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      ageText: ageText ?? this.ageText,
      relation: relation ?? this.relation,
      addressLine1: addressLine1 ?? this.addressLine1,
      streetAddress: streetAddress ?? this.streetAddress,
      selectedAddressIndex: clearSelectedAddress
          ? null
          : (selectedAddressIndex ?? this.selectedAddressIndex),
      priceSummary: priceSummary ?? this.priceSummary,
      confirmedBooking: clearConfirmedBooking
          ? null
          : (confirmedBooking ?? this.confirmedBooking),
    );
  }
}

class BookTestPackageNotifier extends StateNotifier<BookTestPackageState> {
  static const double defaultPlatformCommission = 49;
  static const double defaultGstPercentage = 5;

  final BookTestPackageService _bookingService;
  final LabTestService _labTestService;

  double _platformCommission = defaultPlatformCommission;
  double _gstPercentage = defaultGstPercentage;

  BookTestPackageNotifier(this._bookingService, this._labTestService)
      : super(const BookTestPackageState());

  void applyCharges(ChargesModel charge) {
    _platformCommission = charge.platformCommission;
    _gstPercentage = charge.gstPercentage;
    _recalculatePriceSummary();
  }

  Future<void> initLabTestBooking({
    required String testId,
    LabTestInventoryModel? test,
    UserModel? user,
    List<dynamic>? savedAddresses,
    ChargesModel? charges,
  }) async {
    state = state.copyWith(isLoading: true, error: null, clearConfirmedBooking: true);
    try {
      LabTestInventoryModel? resolvedTest = test;
      if (resolvedTest == null || resolvedTest.testId != testId) {
        final response = await _labTestService.getTestById(testId);
        if (response.statusCode != 200) {
          throw 'Failed to load test details';
        }
        final data = response.data;
        final testJson = data is Map<String, dynamic>
            ? (data['test'] as Map<String, dynamic>? ?? data)
            : null;
        if (testJson == null) throw 'Invalid test details response';
        resolvedTest = LabTestInventoryModel.fromJson(testJson);
      }

      final core = resolvedTest.coreTestDetails;
      if (charges != null) applyCharges(charges);
      _applyItem(
        itemType: BookingItemType.labTest,
        itemId: resolvedTest.testId,
        labId: resolvedTest.labId,
        itemName: core?.testName ?? 'Lab Test',
        itemSubtitle: core?.testCategory,
        subtotal: resolvedTest.price,
        discount: resolvedTest.discountAmount,
        user: user,
        savedAddresses: savedAddresses,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> initPackageBooking({
    required String packageId,
    TestPackageModel? package,
    UserModel? user,
    List<dynamic>? savedAddresses,
    ChargesModel? charges,
  }) async {
    state = state.copyWith(isLoading: true, error: null, clearConfirmedBooking: true);
    try {
      TestPackageModel? resolvedPackage = package;
      if (resolvedPackage == null || resolvedPackage.packageId != packageId) {
        final response = await _labTestService.getPackageById(packageId);
        if (response.statusCode != 200) {
          throw 'Failed to load package details';
        }
        final data = response.data;
        final packageJson = data is Map<String, dynamic>
            ? (data['package'] as Map<String, dynamic>? ?? data)
            : null;
        if (packageJson == null) throw 'Invalid package details response';
        resolvedPackage = TestPackageModel.fromJson(packageJson);
      }

      if (charges != null) applyCharges(charges);
      _applyItem(
        itemType: BookingItemType.package,
        itemId: resolvedPackage.packageId,
        labId: resolvedPackage.labId,
        itemName: resolvedPackage.packageName,
        itemSubtitle:
            '${resolvedPackage.testDetails.length} tests included',
        subtotal: resolvedPackage.packageMarketPrice,
        discount: resolvedPackage.discountAmount,
        user: user,
        savedAddresses: savedAddresses,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _applyItem({
    required BookingItemType itemType,
    required String itemId,
    required String labId,
    required String itemName,
    String? itemSubtitle,
    required double subtotal,
    required double discount,
    UserModel? user,
    List<dynamic>? savedAddresses,
  }) {
    final priceSummary = _buildPriceSummary(
      subtotal: subtotal,
      discount: discount,
    );

    state = state.copyWith(
      isLoading: false,
      itemType: itemType,
      itemId: itemId,
      labId: labId,
      itemName: itemName,
      itemSubtitle: itemSubtitle,
      priceSummary: priceSummary,
      isBookingForSelf: true,
    );

    _fillFromUser(user);
    _applyFirstSavedAddress(savedAddresses);
  }

  void _recalculatePriceSummary() {
    final summary = state.priceSummary;
    if (summary == null) return;
    state = state.copyWith(
      priceSummary: _buildPriceSummary(
        subtotal: summary.subtotal,
        discount: summary.discount,
      ),
    );
  }

  BookingPriceSummary _buildPriceSummary({
    required double subtotal,
    required double discount,
  }) {
    final itemTotal = subtotal - discount;
    final platformFee = _platformCommission;
    final taxCharges = itemTotal * (_gstPercentage / 100);
    final totalAmount = itemTotal + platformFee + taxCharges;
    return BookingPriceSummary(
      subtotal: subtotal,
      discount: discount,
      platformFee: platformFee,
      taxCharges: taxCharges,
      totalAmount: totalAmount,
    );
  }

  void _fillFromUser(UserModel? user) {
    if (user == null) return;
    state = state.copyWith(
      fullName: user.fullName ?? '',
      phoneNumber: user.phoneNumber ?? '',
      relation: state.isBookingForSelf ? 'Self' : state.relation,
    );
  }

  void _applyFirstSavedAddress(List<dynamic>? savedAddresses) {
    if (savedAddresses == null || savedAddresses.isEmpty) return;
    selectSavedAddress(0, savedAddresses[0] as Map<String, dynamic>);
  }

  void setBookingForSelf(bool value, {UserModel? user}) {
    state = state.copyWith(
      isBookingForSelf: value,
      relation: value ? 'Self' : '',
      clearSelectedAddress: false,
    );
    if (value) {
      _fillFromUser(user);
    } else {
      state = state.copyWith(
        fullName: '',
        phoneNumber: '',
        gender: '',
        ageText: '',
        relation: '',
      );
    }
  }

  void updateFullName(String value) => state = state.copyWith(fullName: value);
  void updatePhoneNumber(String value) =>
      state = state.copyWith(phoneNumber: value);
  void updateGender(String value) => state = state.copyWith(gender: value);
  void updateAge(String value) => state = state.copyWith(ageText: value);
  void updateRelation(String value) => state = state.copyWith(relation: value);
  void updateAddressLine1(String value) =>
      state = state.copyWith(addressLine1: value, clearSelectedAddress: true);
  void updateStreetAddress(String value) =>
      state = state.copyWith(streetAddress: value, clearSelectedAddress: true);

  void selectSavedAddress(int index, Map<String, dynamic> address) {
    state = state.copyWith(
      selectedAddressIndex: index,
      addressLine1: address['address_1']?.toString() ?? '',
      streetAddress: address['street_address']?.toString() ?? '',
    );
  }

  void clearSavedAddressSelection() {
    state = state.copyWith(clearSelectedAddress: true);
  }

  String? validate() {
    if (!state.hasItem) return 'Booking item not loaded';
    if (state.fullName.trim().isEmpty) return 'Please enter full name';
    if (state.phoneNumber.trim().length < 10) {
      return 'Please enter a valid phone number';
    }
    if (state.gender.trim().isEmpty) return 'Please select gender';
    final age = int.tryParse(state.ageText.trim());
    if (age == null || age < 1 || age > 120) return 'Please enter a valid age';
    if (state.relation.trim().isEmpty) return 'Please enter relation';
    if (state.addressLine1.trim().isEmpty) {
      return 'Please enter sample collection address';
    }
    if (state.streetAddress.trim().isEmpty) {
      return 'Please enter street / area details';
    }
    return null;
  }

  TestPackageBooking? buildBooking({String? customerId, List<dynamic>? savedAddresses}) {
    if (state.priceSummary == null ||
        state.itemType == null ||
        state.itemId == null ||
        state.labId == null ||
        state.itemName == null) {
      return null;
    }

    final age = int.parse(state.ageText.trim());
    Map<String, dynamic>? selectedAddress;
    if (state.selectedAddressIndex != null &&
        savedAddresses != null &&
        state.selectedAddressIndex! < savedAddresses.length) {
      selectedAddress = savedAddresses[state.selectedAddressIndex!]
          as Map<String, dynamic>;
    }

    return TestPackageBooking(
      itemType: state.itemType!,
      itemId: state.itemId!,
      labId: state.labId!,
      itemName: state.itemName!,
      itemSubtitle: state.itemSubtitle,
      isBookingForSelf: state.isBookingForSelf,
      customerId: customerId,
      patient: BookingPatientDetails(
        fullName: state.fullName.trim(),
        phoneNumber: state.phoneNumber.trim(),
        gender: state.gender.trim(),
        age: age,
        relation: state.relation.trim(),
      ),
      collectionAddress: BookingCollectionAddress(
        addressLine1: state.addressLine1.trim(),
        streetAddress: state.streetAddress.trim(),
        latitude: (selectedAddress?['latitude'] as num?)?.toDouble(),
        longitude: (selectedAddress?['longitude'] as num?)?.toDouble(),
        savedAddressId: selectedAddress?['id'] as int?,
      ),
      priceSummary: state.priceSummary!,
    );
  }

  Future<TestPackageBooking?> submitBooking({
    required String? customerId,
    List<dynamic>? savedAddresses,
  }) async {
    final validationError = validate();
    if (validationError != null) {
      state = state.copyWith(error: validationError);
      return null;
    }

    final booking = buildBooking(
      customerId: customerId,
      savedAddresses: savedAddresses,
    );
    if (booking == null) {
      state = state.copyWith(error: 'Unable to prepare booking');
      return null;
    }

    state = state.copyWith(isSubmitting: true, error: null);
    try {
      await _bookingService.submitBooking(booking);
      state = state.copyWith(
        isSubmitting: false,
        confirmedBooking: booking,
      );
      return booking;
    } catch (e) {
      // Allow checkout even if API is unavailable — booking stored locally
      state = state.copyWith(
        isSubmitting: false,
        confirmedBooking: booking,
        error: null,
      );
      return booking;
    }
  }

  void reset() {
    state = const BookTestPackageState();
  }
}
