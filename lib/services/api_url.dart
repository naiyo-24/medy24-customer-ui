import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiUrl {
  // Read base URL from .env, fallback to localhost if not found
  static String get baseUrl =>
      // dotenv.env['API_BASE_URL'] ?? "http://192.168.0.222:8009";
      dotenv.env['API_BASE_URL'] ?? "http://192.168.0.222:8000";
  // About Us Endpoints
  static String get aboutUs => "$baseUrl/about-us";
  static String get getAboutUsAll => "$aboutUs/get-all";
  static String getAboutUsById(int id) => "$aboutUs/get-by/$id";

  // Terms and Conditions Endpoints
  static String get termsConditions => "$baseUrl/terms-conditions";
  static String get getTermsConditionsAll => "$termsConditions/get-all";

  // Privacy Policy Endpoints
  static String get privacyPolicies => "$baseUrl/privacy-policies";
  static String get getPrivacyPoliciesAll => "$privacyPolicies/get-all";

  // Patho Lab Endpoints
  static String get pathoLab => "$baseUrl/auth/patho-lab";
  static String get getPathoLabAll => "$pathoLab/get-all";
  static String getPathoLabById(String id) => "$pathoLab/get-by/$id";

  // Lab Test Inventory Endpoints
  static String get labTestInventory => "$baseUrl/lab-test-inventory";
  static String get getLabTestAll => "$labTestInventory/get-all";
  static String getLabTestById(String id) => "$labTestInventory/get-by/$id";
  static String getLabTestsByLabId(String labId) =>
      "$labTestInventory/get-by-lab/$labId";

  // Test Package Endpoints
  static String get testPackage => "$baseUrl/test-packages";
  static String get getTestPackageAll =>
      "$testPackage/get-all"; // Assuming it exists or will be needed
  static String getTestPackageById(String id) => "$testPackage/get-by/$id";
  static String getTestPackagesByLabId(String labId) =>
      "$testPackage/get-by-lab/$labId";

  // Lab Test / Package Booking Endpoints
  static String get testPackageBooking => "$baseUrl/test-package-bookings";
  static String get createTestPackageBooking =>
      "$testPackageBooking/create-booking";
  static String getCustomerBookings(String customerId) =>
      "$testPackageBooking/customer/$customerId";
  static String updateTestPackageBooking(String bookingId) =>
      "$testPackageBooking/update/$bookingId";

  // Customer Auth Endpoints
  static String get customers => "$baseUrl/customers";
  static String get checkPhone => "$baseUrl/api/auth/customer/check-phone";
  static String get sendOtp => "$customers/send-otp";
  static String get customerLogin => "$baseUrl/api/auth/customer/login";
  static String getProfile(String id) => "$customers/get-profile/$id";
  static String updateProfile(String id) => "$customers/profile/$id";
  static String addAddress(String id) => "$customers/add-addresses/$id";
  static String deleteAddress(String customerId, int addressId) =>
      "$customers/delete-address/$customerId/$addressId";

  // GraphQL Endpoint
  static String get graphql => "$baseUrl/graphql";

  // Medicine Inventory Endpoints
  static String get medicineInventory => "$baseUrl/medicines";
  static String get getMedicineAll => "$medicineInventory/get-all";
  static String get searchMedicines => "$medicineInventory/search";
  static String getMedicineById(String id) => "$medicineInventory/get-by/$id";

  // Helper for image URLs
  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return "$baseUrl/$cleanPath";
  }

  // Cart Endpoints
  static String get cart => "$baseUrl/cart";
  static String get cartAddItem => "$cart/add-item";
  static String cartUpdateItem(String medicineId) =>
      "$cart/update-item/$medicineId";
  static String cartRemoveItem(String medicineId) =>
      "$cart/remove-item/$medicineId";
  static String get cartGet => "$cart/"; // New endpoint GET /
  static String get cartGetAll => "$cart/get-all"; // Legacy
  static String get cartClear => "$cart/clear";
  static String get cartSummary => "$cart/summary";

  // Orders Endpoints
  static String get ordersBase => "$baseUrl/api/rest/orders";
  static String get placeOrder => "$ordersBase/place";
  static String acceptBid(String orderId) => "$ordersBase/$orderId/accept-bid";

  // WebSocket Endpoints for Orders
  static String biddingWebSocket(String orderId) {
    final wsBaseUrl = baseUrl.replaceFirst('http', 'ws');
    return "$wsBaseUrl/ws/bidding/customer/${Uri.encodeComponent(orderId)}";
  }

  static String trackingWebSocket(String orderId) {
    final wsBaseUrl = baseUrl.replaceFirst('http', 'ws');
    return "$wsBaseUrl/ws/tracking/customer/${Uri.encodeComponent(orderId)}";
  }

  // Platform Fee Endpoints
  static String get platformFee => "$baseUrl/admin/earnings/list";

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
