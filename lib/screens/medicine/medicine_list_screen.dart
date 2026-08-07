import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/home_top_header.dart';
import '../../widgets/home_search_input.dart';
import '../../widgets/promo_banner_carousel.dart';
import '../../models/advertisement.dart';
import '../../widgets/section_header.dart';
import '../../widgets/medicine_categories_row.dart';
import '../../widgets/medicine_horizontal_list.dart';
import '../../widgets/popular_brands_row.dart';
import '../../cards/medicine/medicine_card.dart';

class MedicineListScreen extends ConsumerStatefulWidget {
  const MedicineListScreen({super.key});

  @override
  ConsumerState<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends ConsumerState<MedicineListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => ref.read(medicineProvider.notifier).fetchAllMedicines(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(medicineProvider.notifier).fetchAllMedicines(loadMore: true);
    }
  }

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
    final medicineState = ref.watch(medicineProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final location = _getLocation(user);
    final userName = user?.fullName ?? user?.phoneNumber ?? 'Guest';
    final cartState = ref.watch(cartProvider);
    final cartCount = cartState.items.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(medicineProvider.notifier).fetchAllMedicines(),
        child: CustomScrollView(
          controller: _scrollController,
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
                        id: 'demo1',
                        title: 'Flat 20% OFF',
                        imageUrl: 'https://images.unsplash.com/photo-1585435557343-3b092031a831?q=80&w=800&auto=format&fit=crop',
                        isActive: true,
                        createdAt: DateTime.now(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Browse Categories
                SectionHeader(
                  title: 'Browse Categories',
                  onSeeAllTap: () {},
                ),
                MedicineCategoriesRow(
                  onCategoryTap: (category) {
                    // Filter logic or navigation
                  },
                ),
                const SizedBox(height: 16),

                // Top Deals on Medicines
                SectionHeader(
                  title: 'Top Deals on Medicines',
                  onSeeAllTap: () {},
                ),
                if (medicineState.isLoading && medicineState.medicines.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (medicineState.medicines.isNotEmpty)
                  MedicineHorizontalList(medicines: medicineState.medicines.take(5).toList()),
                
                const SizedBox(height: 16),

                // Popular Brands
                SectionHeader(
                  title: 'Popular Brands',
                  onSeeAllTap: () {},
                ),
                PopularBrandsRow(
                  onBrandTap: (brand) {},
                ),
                const SizedBox(height: 16),

                // Frequently Ordered Header
                SectionHeader(
                  title: 'Frequently Ordered',
                  onSeeAllTap: () {},
                ),
              ]),
            ),

            // Frequently Ordered Vertical List
            if (medicineState.medicines.length > 5)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final medicine = medicineState.medicines[index + 5];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SizedBox(
                          height: 140, // Height bound for the MedicineCard if it's meant to be square-ish
                          child: MedicineCard(
                            medicine: medicine,
                            onTap: () {
                              ref
                                  .read(medicineProvider.notifier)
                                  .selectMedicine(medicine);
                              context.push('/medicine-details');
                            },
                          ),
                        ),
                      );
                    },
                    childCount: medicineState.medicines.length - 5,
                  ),
                ),
              )
            else if (!medicineState.isLoading && medicineState.medicines.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No medicines found')),
              ),

            if (medicineState.isFetchingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
