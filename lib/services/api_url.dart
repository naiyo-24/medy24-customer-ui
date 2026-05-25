import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiUrl {
  static const String baseUrl =
      "http://10.0.2.2:8000"; // Update for real device if needed
  // static const String baseUrl = "http://192.168.1.44:8000";
  // static const String baseUrl = "http://0.0.0.0:8000";
  // About Us Endpoints
  static const String aboutUs = "$baseUrl/about-us";
  static const String getAboutUsAll = "$aboutUs/get-all";
  static String getAboutUsById(int id) => "$aboutUs/get-by/$id";

  // Terms and Conditions Endpoints
  static const String termsConditions = "$baseUrl/terms-conditions";
  static const String getTermsConditionsAll = "$termsConditions/get-all";

  // Privacy Policy Endpoints
  static const String privacyPolicies = "$baseUrl/privacy-policies";
  static const String getPrivacyPoliciesAll = "$privacyPolicies/get-all";

  // Patho Lab Endpoints
  static const String pathoLab = "$baseUrl/auth/patho-lab";
  static const String getPathoLabAll = "$pathoLab/get-all";
  static String getPathoLabById(String id) => "$pathoLab/get-by/$id";

  // Lab Test Inventory Endpoints
  static const String labTestInventory = "$baseUrl/lab-test-inventory";
  static const String getLabTestAll = "$labTestInventory/get-all";
  static String getLabTestById(String id) => "$labTestInventory/get-by/$id";
  static String getLabTestsByLabId(String labId) =>
      "$labTestInventory/get-by-lab/$labId";

  // Test Package Endpoints
  static const String testPackage = "$baseUrl/test-packages";
  static const String getTestPackageAll =
      "$testPackage/get-all"; // Assuming it exists or will be needed
  static String getTestPackageById(String id) => "$testPackage/get-by/$id";
  static String getTestPackagesByLabId(String labId) =>
      "$testPackage/get-by-lab/$labId";

  // Lab Test / Package Booking Endpoints
  static const String testPackageBooking = "$baseUrl/test-package-bookings";
  static const String createTestPackageBooking =
      "$testPackageBooking/create-booking";
  static String getCustomerBookings(String customerId) =>
      "$testPackageBooking/customer/$customerId";
  static String updateTestPackageBooking(String bookingId) =>
      "$testPackageBooking/update/$bookingId";

  // Customer Auth Endpoints
  static const String customers = "$baseUrl/customers";
  static const String checkPhone = "$customers/check-phone";
  static const String sendOtp = "$customers/send-otp";
  static const String verifyOtp = "$customers/verify-otp";
  static String getProfile(String id) => "$customers/get-profile/$id";
  static String updateProfile(String id) => "$customers/profile/$id";
  static String addAddress(String id) => "$customers/add-addresses/$id";
  static String deleteAddress(String customerId, int addressId) =>
      "$customers/delete-address/$customerId/$addressId";

  // Medicine Inventory Endpoints
  static const String medicineInventory = "$baseUrl/medicines";
  static const String getMedicineAll = "$medicineInventory/get-all";
  static const String searchMedicines = "$medicineInventory/search";
  static String getMedicineById(String id) => "$medicineInventory/get-by/$id";

  // Helper for image URLs
  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "$baseUrl/$cleanPath";
  }

  // Cart Endpoints
  static const String cart = "$baseUrl/cart";
  static const String cartAddItem = "$cart/add-item";
  static String cartUpdateItem(String medicineId) => "$cart/update-item/$medicineId";
  static String cartRemoveItem(String medicineId) => "$cart/remove-item/$medicineId";
  static const String cartGet = "$cart/"; // New endpoint GET /
  static const String cartGetAll = "$cart/get-all"; // Legacy
  static const String cartClear = "$cart/clear";
  static const String cartSummary = "$cart/summary";

  // Medicine Orders Endpoints
  static const String orders = "$baseUrl/orders";
  static const String orderPlaceFromCart = "$orders/place-from-cart";
  static const String orderPlaceFromPrescription = "$orders/place-from-prescription";
  static const String orderGetAll = "$orders/get-all";
  static String orderGetById(String id) => "$orders/get-by-id/$id";
  static String orderCancel(String id) => "$orders/$id/cancel";
  static String orderInitiateOnlinePayment(String id) => "$orders/$id/initiate-online-payment";
  static String orderVerifyOnlinePayment(String id) => "$orders/$id/verify-online-payment";

  // Platform Fee Endpoints
  static const String platformFee =
      "http://192.168.0.222:8000/admin/earnings/list";

  /// Get Razorpay Key ID from environment variables
  static String get razorpayKeyId {
    final key = dotenv.env['RAZORPAY_KEY_ID'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'RAZORPAY_KEY_ID not found in .env file. '
        'Please add RAZORPAY_KEY_ID=your_key_id to .env file.',
      );
    }
    return key;
  }
}
