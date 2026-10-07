import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../models/manufacturer_models.dart';
import '../../../providers/manufacturer_provider.dart';

class ManufacturerListScreen extends ConsumerWidget {
  const ManufacturerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manufacturersAsyncValue = ref.watch(manufacturersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Procure Stock',
                  style: AppTextStyles.header.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  'Order in bulk directly from top manufacturers.',
                  style: AppTextStyles.description,
                ),
              ],
            ),
          ),
          Expanded(
            child: manufacturersAsyncValue.when(
              data: (manufacturers) {
                if (manufacturers.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async => ref.refresh(manufacturersProvider),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text('No manufacturers found.')),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.refresh(manufacturersProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                    itemCount: manufacturers.length,
                  itemBuilder: (context, index) {
                    final manufacturer = manufacturers[index];
                    return _buildManufacturerCard(context, manufacturer);
                  },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManufacturerCard(BuildContext context, ManufacturerModel manufacturer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: BorderSide(color: AppColors.divider.withAlpha(128)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: () {
          context.push('/manufacturer-catalog', extra: manufacturer);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 60,
                  height: 60,
                  color: AppColors.background,
                  child: Image.network(
                    manufacturer.logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.factory, color: AppColors.textSecondary);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manufacturer.name,
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Min Order: ${manufacturer.minimumOrderAmount}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
