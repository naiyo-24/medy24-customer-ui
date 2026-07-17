import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bar.dart';
import '../../providers/profile_provider.dart';
import '../../cards/profile/saved_address_card.dart';
import '../../cards/profile/add_saved_address_bottomsheet.dart';

class SavedAddressesScreen extends ConsumerWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final addresses = profileState.user?.savedAddresses ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        showBackButton: true,
        title: 'My Addresses',
        subtitle: 'Manage your delivery locations',
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddSavedAddressBottomSheet(),
              );
            },
            icon: const Icon(Iconsax.add_square, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.location_add,
                    size: 64,
                    color: AppColors.textTertiary.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No addresses saved yet',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final address = addresses[index];
                return SavedAddressCard(
                  address: address,
                  onDelete: () async {
                    final success = await ref
                        .read(profileProvider.notifier)
                        .deleteAddress(address['address_id']);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address deleted')),
                      );
                    }
                  },
                  onEdit: () {
                    // Logic for editing can be similar to add
                  },
                );
              },
            ),
    );
  }
}
