import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/home_top_header.dart';
import '../../widgets/home_search_input.dart';
import '../../widgets/promo_banner_carousel.dart';
import '../../models/advertisement.dart';
import '../../widgets/section_header.dart';
import '../../widgets/lab_test_categories_row.dart';
import '../../widgets/health_packages_horizontal_list.dart';
import '../../widgets/why_choose_us_row.dart';
import '../../widgets/top_health_tests_list.dart';

class LabTestSearchScreen extends ConsumerStatefulWidget {
  const LabTestSearchScreen({super.key});

  @override
  ConsumerState<LabTestSearchScreen> createState() => _LabTestSearchScreenState();
}

class _LabTestSearchScreenState extends ConsumerState<LabTestSearchScreen> {

  String _getLocation(dynamic user) {
    try {
      final saved = user?.savedAddresses as List<dynamic>?;
      if (saved != null && saved.isNotEmpty) {
        final first = saved.first as Map<String, dynamic>?;
        final addr = first?['address_1'] as String?;
        if (addr != null && addr.isNotEmpty) return addr;
      }
    } catch (_) {}
    return 'Kolkata 700086';
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
          // ── Top Header
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: HomeTopHeader(
                userName: userName,
                profilePhoto: user?.profilePhoto,
                location: location,
                deliveryTime: '30 mins',
                cartCount: cartCount,
                onLocationTap: () => context.push('/map-picker'),
                onCartTap: () => context.push('/cart'),
                onProfileTap: () => context.push('/profile'),
              ),
            ),
          ),
          
          // ── Search Input
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
            toolbarHeight: 75,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  HomeSearchInput(
                    onTap: () => context.push('/medicine-search'),
                  ),
                ],
              ),
            ),
          ),

          // ── Body Content
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              // Promo Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PromoBannerCarousel(
                  banners: [
                    AdvertisementModel(
                      id: 'demo_lab',
                      title: 'Up to 15% OFF on Lab Tests',
                      imageUrl: 'https://images.unsplash.com/photo-1579154204601-01588f351e67?q=80&w=800&auto=format&fit=crop',
                      isActive: true,
                      createdAt: DateTime.now(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Popular Test Categories
              SectionHeader(
                title: 'Popular Test Categories',
                onSeeAllTap: () {},
              ),
              LabTestCategoriesRow(
                onCategoryTap: (category) {
                  // Navigate or filter
                },
              ),
              const SizedBox(height: 16),

              // Health Packages For You
              SectionHeader(
                title: 'Health Packages For You',
                onSeeAllTap: () {},
              ),
              HealthPackagesHorizontalList(
                onBookTap: (package) {},
              ),
              const SizedBox(height: 16),

              // Why Choose Us
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Why Choose Medy24 Lab Tests?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const WhyChooseUsRow(),
              const SizedBox(height: 16),

              // Top Health Tests Header
              SectionHeader(
                title: 'Top Health Tests',
                onSeeAllTap: () {},
              ),
              
              // Vertical List of Health Tests
              TopHealthTestsList(
                onAddTap: (testName) {},
              ),

              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }
}
