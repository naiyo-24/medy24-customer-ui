import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../providers/medicine_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/order_with_prescription_card.dart';
import '../../widgets/app_bar.dart';
import '../../cards/medicine/medicine_card.dart';
import '../../providers/cart_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final medicineState = ref.watch(medicineProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Medicines',
        subtitle: 'Order from your nearest pharmacy',
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: () => context.push('/medicine-search'),
            icon: const Icon(Iconsax.search_normal_1),
          ),
          IconButton(
            onPressed: () => _showFilterBottomSheet(context),
            icon: const Icon(Iconsax.filter_edit),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () => context.push('/cart'),
                icon: const Icon(Iconsax.shopping_cart),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final cartItemCount = ref.watch(cartProvider).items.length;
                  if (cartItemCount == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartItemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(medicineProvider.notifier).fetchAllMedicines(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  16,
                  AppSpacing.screenPadding,
                  8,
                ),
                child: OrderWithPrescriptionCard(
                  onTap: () => context.push('/order-with-prescription'),
                ),
              ),
            ),
            if (medicineState.isLoading && medicineState.medicines.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (medicineState.error != null)
              SliverFillRemaining(
                child: Center(child: Text(medicineState.error!)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: AppSpacing.elementGap,
                    mainAxisSpacing: AppSpacing.elementGap,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final medicine = medicineState.medicines[index];
                    return MedicineCard(
                      medicine: medicine,
                      onTap: () {
                        ref
                            .read(medicineProvider.notifier)
                            .selectMedicine(medicine);
                        context.push('/medicine-details');
                      },
                    );
                  }, childCount: medicineState.medicines.length),
                ),
              ),
            if (medicineState.isFetchingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final currentRange = ref
            .read(medicineProvider)
            .listPriceRange
            ?.firstOrNull;
        String initialSelection = 'All';
        if (currentRange == '0-100') {
          initialSelection = 'Under 100';
        } else if (currentRange == '100-500') {
          initialSelection = '100-500';
        } else if (currentRange == '500-1000') {
          initialSelection = '500-1000';
        } else if (currentRange == '1000-5000') {
          initialSelection = '1000-5000';
        } else if (currentRange == '5000+') {
          initialSelection = 'Above 5000';
        }

        return _FilterBottomSheet(
          initialSelection: initialSelection,
          onApply: (priceRangeLabel) {
            context.pop();
            if (priceRangeLabel == null || priceRangeLabel == 'All') {
              ref
                  .read(medicineProvider.notifier)
                  .fetchAllMedicines(clearFilter: true);
            } else {
              List<String> range = [];
              if (priceRangeLabel == 'Under 100') {
                range = ['0-100'];
              } else if (priceRangeLabel == '100-500') {
                range = ['100-500'];
              } else if (priceRangeLabel == '500-1000') {
                range = ['500-1000'];
              } else if (priceRangeLabel == '1000-5000') {
                range = ['1000-5000'];
              } else if (priceRangeLabel == 'Above 5000') {
                range = ['5000+'];
              }

              ref
                  .read(medicineProvider.notifier)
                  .fetchAllMedicines(priceRange: range);
            }
          },
        );
      },
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final String initialSelection;
  final Function(String?) onApply;

  const _FilterBottomSheet({
    required this.initialSelection,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _selectedRange;

  final List<String> _priceRanges = [
    'All',
    'Under 100',
    '100-500',
    '500-1000',
    '1000-5000',
    'Above 5000',
  ];

  @override
  void initState() {
    super.initState();
    _selectedRange = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter by Price',
                style: AppTextStyles.header.copyWith(fontSize: 20),
              ),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Iconsax.close_circle,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: _priceRanges.map((range) {
              final isSelected = _selectedRange == range;
              return ChoiceChip(
                label: Text(range),
                selected: isSelected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: AppColors.surface,
                onSelected: (selected) {
                  setState(() {
                    _selectedRange = range;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_selectedRange),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Apply Filter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
