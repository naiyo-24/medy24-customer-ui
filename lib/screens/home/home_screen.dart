import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/home_top_header.dart';
import '../../widgets/home_search_input.dart';
import '../../widgets/promo_banner_carousel.dart';
import '../../widgets/home_service_grid.dart';
import '../../widgets/home_order_via_section.dart';
import '../../widgets/footer_card.dart';
import '../../widgets/category_content_sliver.dart';
import '../../providers/medicine_provider.dart';
import '../../cards/medicine/medicine_card.dart';
import '../../widgets/welcome_popup.dart';
import '../../providers/order_provider.dart';
import '../../cards/medicine_orders/order_card.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(medicineProvider.notifier).fetchAllMedicines(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowWelcomePopup();
    });
  }

  Future<void> _checkAndShowWelcomePopup() async {
    final prefs = await SharedPreferences.getInstance();
    
    // TEMPORARY: Reset the memory flag so you can test it again!
    await prefs.remove('has_seen_welcome_popup');
    
    final hasSeen = prefs.getBool('has_seen_welcome_popup') ?? false;
    
    if (!hasSeen) {
      if (!mounted) return;
      
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const WelcomePopup(),
      );
      
      await prefs.setBool('has_seen_welcome_popup', true);
    }
  }

  String _getLocation(dynamic user) {
    try {
      final saved = user?.savedAddresses as List<dynamic>?;
      if (saved != null && saved.isNotEmpty) {
        final first = saved.first as Map<String, dynamic>?;
        final addr = first?['address1'] as String?;
        if (addr != null && addr.isNotEmpty) return addr;
      }
    } catch (_) {}
    return 'Kolkata 700086';
  }

  Future<void> _launchWhatsApp() async {
    // WhatsApp ordering — can integrate url_launcher if added to pubspec
    context.push('/order-with-prescription');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final location = _getLocation(user);
    final userName = user?.fullName ?? user?.phoneNumber ?? 'Guest';
    final cartState = ref.watch(cartProvider);
    final cartCount = cartState.items.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Top Header (Dynamically Sized)
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: HomeTopHeader(
                userName: userName,
                location: location,
                deliveryTime: '30 mins',
                cartCount: cartCount,
                onLocationTap: () => context.push('/map-picker'),
                onCartTap: () => context.push('/cart'),
                onProfileTap: () => context.push('/profile'),
              ),
            ),
          ),
          
          // ── Sticky Search
          SliverAppBar(
            pinned: true,
            floating: false,
            primary: false,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 2,
            shadowColor: Colors.black.withAlpha(20),
            automaticallyImplyLeading: false,
            toolbarHeight: 65, // Accommodates Search
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Search Bar
                  HomeSearchInput(
                    onTap: () => context.push('/medicine-search'),
                  ),
                ],
              ),
            ),
          ),

          // ── Scrollable Body
          if (_selectedTabIndex > 0)
            const CategoryContentSliver()
          else
            SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              // ── Promo Banner Carousel (auto-scrolls every 3s)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PromoBannerCarousel(
                  banners: const [
                    PromoBannerItem(
                      badge: '🎉 BEST OFFER',
                      title: 'GET 20% OFF',
                      subtitle: 'on medicines and essentials',
                      gradientColors: [Color(0xFF005A6B), Color(0xFF008396), Color(0xFF7C3AED)],
                      icon: Icons.local_pharmacy_outlined,
                    ),
                    PromoBannerItem(
                      badge: '🧪 LAB SPECIAL',
                      title: 'FLAT 15% OFF',
                      subtitle: 'on all lab tests & packages',
                      gradientColors: [Color(0xFF0F766E), Color(0xFF14B8A6), Color(0xFF0EA5E9)],
                      icon: Icons.science_outlined,
                    ),
                    PromoBannerItem(
                      badge: '💊 LIMITED TIME',
                      title: 'UP TO 40% OFF',
                      subtitle: 'on health packages for family',
                      gradientColors: [Color(0xFF7C3AED), Color(0xFF9333EA), Color(0xFFEC4899)],
                      icon: Icons.family_restroom_outlined,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── 2x2 Service Grid
              HomeServiceGrid(
                items: [
                  HomeServiceGridItem(
                    title: 'Order\nMedicines',
                    subtitle: 'Free Delivery',
                    offerText: '20% off with MEDY20',
                    offerColor: AppColors.primaryAccent,
                    imagePath: 'assets/logo/order_medicine.png',
                    onTap: () => context.push('/medicine-list'),
                  ),
                  HomeServiceGridItem(
                    title: 'Lab Tests &\nPackages',
                    subtitle: 'Free Home Pickup',
                    offerText: 'Flat 15% off',
                    offerColor: AppColors.success,
                    imagePath: 'assets/logo/book_lab_test.png',
                    onTap: () => context.push('/lab-tests'),
                  ),
                  HomeServiceGridItem(
                    title: 'My\nOrders',
                    subtitle: 'Track your items',
                    offerText: 'View past orders',
                    offerColor: AppColors.purple,
                    imagePath: 'assets/logo/patho_lab.png',
                    onTap: () => context.push('/my-medicine-orders'),
                  ),
                  HomeServiceGridItem(
                    title: 'Upload\nPrescription',
                    subtitle: 'We do the rest',
                    offerText: 'Quick & Easy',
                    offerColor: AppColors.warning,
                    imagePath: 'assets/logo/order_with_prescription.png',
                    onTap: () =>
                        context.push('/order-with-prescription'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Featured Medicines Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Medicines',
                      style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/medicine-list'),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // ── Featured Medicines List
              Consumer(
                builder: (context, ref, child) {
                  final medicineState = ref.watch(medicineProvider);
                  
                  if (medicineState.isLoading && medicineState.medicines.isEmpty) {
                    return const SizedBox(
                      height: 260,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (medicineState.medicines.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final displayMeds = medicineState.medicines.take(5).toList();

                  return SizedBox(
                    height: 280,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: displayMeds.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final medicine = displayMeds[index];
                        return SizedBox(
                          width: 160,
                          child: MedicineCard(
                            medicine: medicine,
                            onTap: () {
                              ref.read(medicineProvider.notifier).selectMedicine(medicine);
                              context.push('/medicine-details');
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ── Order Via Section
              HomeOrderViaSection(
                onWhatsAppTap: _launchWhatsApp,
                onPrescriptionTap: () =>
                    context.push('/order-with-prescription'),
                onCallTap: () {},
              ),



              // ── Recent Section
              Consumer(
                builder: (context, ref, child) {
                  final orderState = ref.watch(orderProvider);
                  if (orderState.orders.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final recentOrders = orderState.orders.take(2).toList();

                  return Column(
                    children: [
                      _RecentHeader(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: recentOrders.map((order) => OrderCard(
                            order: order,
                            onTap: () => context.push('/my-medicine-orders'),
                          )).toList(),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // ── Footer
              const FooterCard(),
              const SizedBox(height: 20),
            ]),
          ),
        ],
      ),
    );
  }
}

/// Section header widget
class _RecentHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recent Orders',
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/my-medicine-orders'),
            child: const Text(
              'View All',
              style: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
