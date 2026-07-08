import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../providers/cart_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_theme.dart';
import '../profile/add_saved_address_bottomsheet.dart';

class CartAddressCard extends ConsumerWidget {
  const CartAddressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    if (cartState.items.isEmpty) return const SizedBox.shrink();

    final profileState = ref.watch(profileProvider);
    final addresses = profileState.user?.savedAddresses ?? [];

    if (addresses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: AppCardStyles.sleekCard,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.location_add, color: AppColors.error, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Saved Addresses',
              style: AppTextStyles.cardTitle,
            ),
            const SizedBox(height: 8),
            Text(
              'Please add an address in your profile to proceed with the checkout.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Close the current address selection sheet first
                  Navigator.of(context).pop();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AddSavedAddressBottomSheet(),
                  );
                },
                icon: const Icon(Iconsax.add_square),
                label: const Text('Add New Address'),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.location, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              const Text('Deliver To', style: AppTextStyles.cardTitle),
            ],
          ),
          const SizedBox(height: 16),
          ...addresses.map((address) {
            final isSelected = cartState.selectedAddress == address;
            return InkWell(
              onTap: () {
                ref.read(cartProvider.notifier).selectAddress(address);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected
                      ? AppColors.primary.withAlpha(25)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Iconsax.location_tick : Iconsax.location,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address['address_1'] ?? 'Address',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (address['street_address'] != null)
                            Text(
                              address['street_address'],
                              style: AppTextStyles.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                // Close the current address selection sheet first
                Navigator.of(context).pop();
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AddSavedAddressBottomSheet(),
                );
              },
              icon: const Icon(Iconsax.add_square),
              label: const Text('Add New Address', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
