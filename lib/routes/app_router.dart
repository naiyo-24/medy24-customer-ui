import 'package:go_router/go_router.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/about_us/about_us_screen.dart';
import '../screens/patho_lab/patho_lab_list_screen.dart';
import '../screens/patho_lab/patho_lab_details_screen.dart';
import '../screens/lab_test/lab_test_list_screen.dart';
import '../screens/lab_test/lab_test_details_screen.dart';
import '../screens/lab_test/test_package_list_screen.dart';
import '../screens/lab_test/test_package_details_screen.dart';
import '../screens/lab_test/my_test_bookings_screen.dart';
import '../screens/medicine/medicine_list_screen.dart';
import '../screens/medicine/medicine_details_screen.dart';
import '../screens/medicine/medicine_search_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/order_medicine/order_with_prescription_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/privacy_policy/privacy_policy_screen.dart';
import '../screens/terms_conditions/terms_conditions_screen.dart';
import '../screens/profile/update_profile_screen.dart';
import '../screens/profile/saved_addresses_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/book_test_package/book_test_package_screen.dart';
import '../screens/payment/checkout_screen.dart';
import '../screens/cart/cart_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/signup/:phone',
      builder: (context, state) {
        final phone = state.pathParameters['phone']!;
        return SignupScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/about-us',
      builder: (context, state) => const AboutUsScreen(),
    ),
    GoRoute(
      path: '/patho-lab-list',
      builder: (context, state) => const PathoLabListScreen(),
    ),
    GoRoute(
      path: '/patho-lab-details/:labId',
      builder: (context, state) {
        final labId = state.pathParameters['labId']!;
        return PathoLabDetailsScreen(labId: labId);
      },
    ),
    GoRoute(
      path: '/lab-test-list',
      builder: (context, state) => const LabTestListScreen(),
    ),
    GoRoute(
      path: '/lab-test-details/:testId',
      builder: (context, state) {
        final testId = state.pathParameters['testId']!;
        return LabTestDetailsScreen(testId: testId);
      },
    ),
    GoRoute(
      path: '/test-package-list',
      builder: (context, state) => const TestPackageListScreen(),
    ),
    GoRoute(
      path: '/test-package-details/:packageId',
      builder: (context, state) {
        final packageId = state.pathParameters['packageId']!;
        return TestPackageDetailsScreen(packageId: packageId);
      },
    ),
    GoRoute(
      path: '/medicine-list',
      builder: (context, state) => const MedicineListScreen(),
    ),
    GoRoute(
      path: '/medicine-details',
      builder: (context, state) => const MedicineDetailsScreen(),
    ),
    GoRoute(
      path: '/medicine-search',
      builder: (context, state) => const MedicineSearchScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/terms-conditions',
      builder: (context, state) => const TermsConditionsScreen(),
    ),
    GoRoute(
      path: '/order-with-prescription',
      builder: (context, state) => const OrderWithPrescriptionScreen(),
    ),
    GoRoute(
      path: '/update-profile',
      builder: (context, state) => const UpdateProfileScreen(),
    ),
    GoRoute(
      path: '/saved-addresses',
      builder: (context, state) => const SavedAddressesScreen(),
    ),
    GoRoute(
      path: '/map-picker',
      builder: (context, state) => const MapPickerScreen(),
    ),
    GoRoute(
      path: '/book-test-package',
      builder: (context, state) {
        final type = state.uri.queryParameters['type'] ?? 'lab_test';
        final itemId = state.uri.queryParameters['itemId'] ?? '';
        return BookTestPackageScreen(bookingType: type, itemId: itemId);
      },
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/my-test-bookings/:customerId',
      builder: (context, state) {
        final customerId = state.pathParameters['customerId']!;
        return MyTestBookingsScreen(customerId: customerId);
      },
    ),
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
  ],
);
