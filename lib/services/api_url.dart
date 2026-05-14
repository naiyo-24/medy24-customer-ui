class ApiUrl {
  // static const String baseUrl =
  //     "http://10.0.2.2:8000"; // Update for real device if needed
  static const String baseUrl = "http://192.168.1.44:8000";
  // static const String baseUrl = "http://0.0.0.0:8000";
  // About Us Endpoints
  static const String aboutUs = "$baseUrl/about-us";
  static const String getAboutUsAll = "$aboutUs/get-all";
  static String getAboutUsById(int id) => "$aboutUs/get-by/$id";

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

  // Helper for image URLs
  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;
    return "$baseUrl/$path";
  }
}
