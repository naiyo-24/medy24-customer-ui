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
import '../../cards/medicine/medicine_design_variants.dart';

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
      () {
        ref.read(medicineProvider.notifier).fetchAllMedicines();
        ref.read(medicineProvider.notifier).fetchPopularBrands();
      }
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
                if (medicineState.popularBrands.length >= 5) ...[
                  SectionHeader(
                    title: 'Popular Brands',
                    onSeeAllTap: () {},
                  ),
                  PopularBrandsRow(
                    brands: medicineState.popularBrands,
                    onBrandTap: (brand) {},
                  ),
                  const SizedBox(height: 16),
                ],

                // Frequently Ordered Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Frequently Ordered',
                    style: AppTextStyles.subHeader.copyWith(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 12),
              ]),
            ),

            // Mixed Design Layout (Changes every 10 items)
            if (medicineState.medicines.length > 5)
              ..._buildDynamicMedicineList(medicineState.medicines.skip(5).toList())
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

  List<Widget> _buildDynamicMedicineList(List<dynamic> medicines) {
    final List<Widget> slivers = [];
    const int chunkSize = 10;
    
    const List<String> sectionHeadings = [
      'Trending Now',
      'Daily Essentials',
      'Popular in Your Area',
      'Best Discounts',
      'Top Rated Medicines',
      'New Arrivals',
      'Recommended for You',
      'Winter Care',
      'Immunity Boosters',
    ];
    
    for (int i = 0; i < medicines.length; i += chunkSize) {
      final chunk = medicines.skip(i).take(chunkSize).toList();
      final chunkIndex = i ~/ chunkSize;
      final designType = (chunkIndex % 6) + 1; // Cycles from 1 to 6
      final headingText = sectionHeadings[chunkIndex % sectionHeadings.length];
      
      // Add a heading for this chunk's design
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  headingText,
                  style: AppTextStyles.subHeader.copyWith(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      );

      slivers.add(
        _buildSliverForChunk(chunk, designType),
      );
    }
    
    return slivers;
  }

  Widget _buildSliverForChunk(List<dynamic> chunk, int designType) {
    if (designType == 2) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => MedicineDesign2(
              medicine: chunk[index],
              onTap: () {
                ref.read(medicineProvider.notifier).selectMedicine(chunk[index]);
                context.push('/medicine-details');
              },
            ),
            childCount: chunk.length,
          ),
        ),
      );
    } else if (designType == 5) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => MedicineDesign5(
              medicine: chunk[index],
              onTap: () {
                ref.read(medicineProvider.notifier).selectMedicine(chunk[index]);
                context.push('/medicine-details');
              },
            ),
            childCount: chunk.length,
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final med = chunk[index];
              void onTap() {
                ref.read(medicineProvider.notifier).selectMedicine(med);
                context.push('/medicine-details');
              }

              if (designType == 1) return MedicineDesign1(medicine: med, onTap: onTap);
              if (designType == 3) return MedicineDesign3(medicine: med, onTap: onTap);
              if (designType == 4) return MedicineDesign4(medicine: med, onTap: onTap);
              if (designType == 6) return MedicineDesign6(medicine: med, onTap: onTap);
              
              return const SizedBox();
            },
            childCount: chunk.length,
          ),
        ),
      );
    }
  }
}
