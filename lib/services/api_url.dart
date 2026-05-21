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
  static const String labTestBooking = "$baseUrl/lab-test-bookings";
  static const String createLabTestBooking = "$labTestBooking/create";
  static const String testPackageBooking = "$baseUrl/test-package-bookings";
  static const String createTestPackageBooking = "$testPackageBooking/create";

  // Customer Auth Endpoints
  static const String customers = "$baseUrl/customers";
  static const String checkPhone = "$customers/check-phone";
  static const String sendOtp = "$customers/send-otp";
  static const String verifyOtp = "$customers/verify-otp";
  static String getProfile(String id) => "$customers/profile/$id";
  static String updateProfile(String id) => "$customers/profile/$id";
  static String addAddress(String id) => "$customers/addresses/$id";
  static String deleteAddress(String customerId, int addressId) =>
      "$customers/addresses/$customerId/$addressId";

  // Medicine Inventory Endpoints
  static const String medicineInventory = "$baseUrl/medicine-inventory";
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

  // Platform Fee Endpoints
  static const String platformFee = "http://192.168.0.222:8000/admin/earnings/list";
}
