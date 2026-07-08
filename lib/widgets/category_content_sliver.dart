import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/medicine_provider.dart';
import '../cards/medicine/medicine_card.dart';
import '../theme/app_theme.dart';

class CategoryContentSliver extends ConsumerWidget {
  const CategoryContentSliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicineProvider);

    if (state.isLoading && !state.isFetchingMoreSearch) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          ),
        ),
      );
    }

    if (state.searchResults.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We are adding new stock soon.',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.65, // Approx aspect ratio for MedicineCard
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final medicine = state.searchResults[index];
            return MedicineCard(
              medicine: medicine,
              onTap: () {
                ref.read(medicineProvider.notifier).selectMedicine(medicine);
                context.push('/medicine-details');
              },
            );
          },
          childCount: state.searchResults.length,
        ),
      ),
    );
  }
}
