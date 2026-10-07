import 'package:customer_app/providers/auth_provider.dart';

import "../screens/b2b/distributor_po_history_screen.dart";
import "../screens/b2b/b2b_order_history_screen.dart";
import 'package:customer_app/screens/order_medicine/order_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/splash_screen.dart';
// import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/profile_creation_screen.dart';
import '../screens/b2b/manufacturer/manufacturer_catalog_screen.dart';
import '../models/manufacturer_models.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/retailer_login_screen.dart';
import '../screens/auth/distributor_login_screen.dart';
import '../screens/auth/retailer_signup_screen.dart';
import '../screens/auth/distributor_signup_screen.dart';
import '../screens/b2b/distributor_dashboard_screen.dart';
import '../screens/order_medicine/my_order_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/about_us/about_us_screen.dart';
import '../screens/lab_tests/lab_test_search_screen.dart';
import '../screens/lab_tests/lab_test_active_search_screen.dart';
import '../screens/lab_tests/lab_selection_screen.dart';
import '../screens/lab_tests/lab_details_screen.dart';
import '../screens/lab_tests/lab_checkout_screen.dart';
import '../screens/lab_tests/lab_booking_success_screen.dart';
import '../screens/lab_tests/lab_booking_waiting_screen.dart';
import '../screens/lab_tests/my_lab_bookings_screen.dart';
import '../screens/lab_tests/lab_test_details_screen.dart';
import '../models/lab_package.dart';
import '../screens/medicine/medicine_list_screen.dart';
import '../screens/medicine/medicine_details_screen.dart';
import '../screens/medicine/medicine_search_screen.dart';
import '../screens/home/home_screen.dart';
// import '../screens/medicine/skin_care_screen.dart';
import '../screens/order_medicine/order_with_prescription_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/support/report_problem_screen.dart';
import '../screens/privacy_policy/privacy_policy_screen.dart';
import '../screens/terms_conditions/terms_conditions_screen.dart';
import '../screens/profile/update_profile_screen.dart';
import '../screens/profile/saved_addresses_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/payment/checkout_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/b2b/b2b_market_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/retailer_bottom_nav_bar.dart';
import '../widgets/floating_cart_pill.dart';
import '../screens/retailer_dashboard/live_orders_screen.dart';
import '../screens/retailer_dashboard/earnings_dashboard_screen.dart';
import '../screens/retailer_dashboard/retailer_profile_screen.dart';
import '../screens/retailer_dashboard/profile/retailer_location_screen.dart';
import '../screens/retailer_dashboard/profile/retailer_bank_details_screen.dart';
import '../screens/retailer_dashboard/profile/retailer_documents_screen.dart';

import '../screens/b2b/b2b_checkout_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorMedsKey = GlobalKey<NavigatorState>(debugLabel: 'meds');
final _shellNavigatorTestsKey = GlobalKey<NavigatorState>(debugLabel: 'tests');
final _shellNavigatorCartKey = GlobalKey<NavigatorState>(debugLabel: 'cart');
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(
  debugLabel: 'profile',
);

final _retailerShellNavigatorLiveOrdersKey = GlobalKey<NavigatorState>(
  debugLabel: 'live_orders',
);
final _retailerShellNavigatorB2bKey = GlobalKey<NavigatorState>(
  debugLabel: 'retailer_b2b',
);
final _retailerShellNavigatorEarningsKey = GlobalKey<NavigatorState>(
  debugLabel: 'earnings',
);
final _retailerShellNavigatorComplianceKey = GlobalKey<NavigatorState>(
  debugLabel: 'compliance',
);

// Global observer to track the current route
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final ValueNotifier<String> currentRouteNotifier = ValueNotifier<String>('');

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name != null) {
      currentRouteNotifier.value = route.settings.name!;
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.settings.name != null) {
      currentRouteNotifier.value = previousRoute!.settings.name!;
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute?.settings.name != null) {
      currentRouteNotifier.value = newRoute!.settings.name!;
    }
  }
}

final globalNavigatorObserver = MyNavigatorObserver();

final appRouter = GoRouter(
  initialLocation: '/splash',
  navigatorKey: _rootNavigatorKey,
  observers: [globalNavigatorObserver],
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    // GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/retailer-login',
      builder: (context, state) => const RetailerLoginScreen(),
    ),
    GoRoute(
      path: '/distributor-login',
      builder: (context, state) => const DistributorLoginScreen(),
    ),
    GoRoute(
      path: '/retailer-signup',
      builder: (context, state) => const RetailerSignupScreen(),
    ),
    GoRoute(
      path: '/distributor-signup',
      builder: (context, state) => const DistributorSignupScreen(),
    ),
    GoRoute(
      path: '/distributor-dashboard',
      builder: (context, state) => const DistributorDashboardScreen(),
    ),
    GoRoute(
      path: '/distributor-po-history',
      builder: (context, state) => const DistributorPoHistoryScreen(),
    ),
    GoRoute(
      path: '/manufacturer-catalog',
      builder: (context, state) {
        final manufacturer = state.extra as ManufacturerModel;
        return ManufacturerCatalogScreen(manufacturer: manufacturer);
      },
    ),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra == null) return const LoginScreen();
        return OtpScreen(
          verificationId: extra['verificationId'] as String,
          phoneNumber: extra['phoneNumber'] as String,
          isNewUser: extra['isNewUser'] as bool? ?? false,
        );
      },
    ),
    GoRoute(
      path: '/profile-creation',
      builder: (context, state) => const ProfileCreationScreen(),
    ),
    GoRoute(
      path: '/signup/:phone',
      builder: (context, state) {
        final phone = state.pathParameters['phone']!;
        return SignupScreen(phoneNumber: phone);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          floatingActionButton: navigationShell.currentIndex == 3
              ? null
              : const FloatingCartPill(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorMedsKey,
          routes: [
            GoRoute(
              path: '/medicine-list',
              builder: (context, state) => const MedicineListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorTestsKey,
          routes: [
            GoRoute(
              path: '/lab-tests',
              builder: (context, state) => const LabTestSearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorCartKey,
          routes: [
            GoRoute(
              path: '/cart',
              builder: (context, state) => const CartScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: RetailerBottomNavBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _retailerShellNavigatorLiveOrdersKey,
          routes: [
            GoRoute(
              path: '/retailer-live-orders',
              builder: (context, state) => const LiveOrdersScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _retailerShellNavigatorB2bKey,
          routes: [
            GoRoute(
              path: '/retailer-b2b-market',
              builder: (context, state) => const B2bMarketScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _retailerShellNavigatorEarningsKey,
          routes: [
            GoRoute(
              path: '/retailer-earnings',
              builder: (context, state) => const EarningsDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _retailerShellNavigatorComplianceKey,
          routes: [
            GoRoute(
              path: '/retailer-profile',
              builder: (context, state) => const RetailerProfileScreen(),
            ),
            GoRoute(
              path: '/retailer-profile/location',
              builder: (context, state) => const RetailerLocationScreen(),
            ),
            GoRoute(
              path: '/retailer-profile/bank',
              builder: (context, state) => const RetailerBankDetailsScreen(),
            ),
            GoRoute(
              path: '/retailer-profile/documents',
              builder: (context, state) => const RetailerDocumentsScreen(),
            ),
            GoRoute(
              path: '/retailer-b2b-orders',
              builder: (context, state) {
                var ref;
                final user = ref.read(authProvider).user;
                return B2BOrderHistoryScreen(shopId: user?.customerId ?? '');
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/lab-selection',
      builder: (context, state) => const LabSelectionScreen(),
    ),
    GoRoute(
      path: '/lab-details',
      builder: (context, state) {
        final lab = state.extra as LabPackage;
        return LabDetailsScreen(lab: lab);
      },
    ),
    GoRoute(
      path: '/lab-checkout',
      builder: (context, state) {
        final lab = state.extra as LabPackage;
        return LabCheckoutScreen(lab: lab);
      },
    ),
    GoRoute(
      path: '/lab-booking-waiting/:bookingId',
      builder: (context, state) {
        final bookingId = state.pathParameters['bookingId']!;
        final labPhone = state.extra as String? ?? "";
        return LabBookingWaitingScreen(
          bookingId: bookingId,
          labPhone: labPhone,
        );
      },
    ),
    GoRoute(
      path: '/lab-booking-success',
      builder: (context, state) {
        final labPhone = state.extra as String;
        return LabBookingSuccessScreen(labPhone: labPhone);
      },
    ),

    GoRoute(
      path: '/about-us',
      builder: (context, state) => const AboutUsScreen(),
    ),
    GoRoute(
      path: '/report-problem',
      builder: (context, state) => const ReportProblemScreen(),
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
      path: '/lab-test-active-search',
      builder: (context, state) => const LabTestActiveSearchScreen(),
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
      path: '/checkout',
      builder: (context, state) {
        final type = state.uri.queryParameters['type'] ?? 'lab_test';
        return CheckoutScreen(checkoutType: type);
      },
    ),
    GoRoute(
      path: '/b2b-checkout',
      builder: (context, state) => const B2bCheckoutScreen(),
    ),
    GoRoute(
      path: '/lab-test-details',
      builder: (context, state) => const LabTestDetailsScreen(),
    ),
    GoRoute(
      path: '/my-medicine-orders',
      builder: (context, state) => const MyOrderScreen(),
    ),
    GoRoute(
      path: '/my-test-bookings/:customerId',
      builder: (context, state) {
        final customerId = state.pathParameters['customerId']!;
        return MyLabBookingsScreen(customerId: customerId);
      },
    ),
    GoRoute(
      name: 'order-tracking',
      path: '/order-tracking/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return OrderTrackingScreen(orderId: orderId);
      },
    ),
  ],
);
