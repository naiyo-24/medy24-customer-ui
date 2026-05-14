import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/lab_test.dart';
import '../../theme/app_theme.dart';
import '../../services/api_url.dart';
import '../../providers/patho_lab_provider.dart';

class LabTestCard extends ConsumerWidget {
  final LabTestInventoryModel test;
  final VoidCallback? onTap;

  const LabTestCard({super.key, required this.test, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final core = test.coreTestDetails;
    if (core == null) return const SizedBox.shrink();

    // Try to find the lab name from the pathoLabProvider
    final labs = ref.watch(pathoLabProvider).labs;
    final lab = labs.where((l) => l.labId == test.labId).firstOrNull;
    final labName = lab?.labName ?? 'Loading lab...';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppCardStyles.sleekCard,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Test Photo
              Container(
                width: 110,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.cardRadius),
                    bottomLeft: Radius.circular(AppSpacing.cardRadius),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.cardRadius),
                    bottomLeft: Radius.circular(AppSpacing.cardRadius),
                  ),
                  child: core.testPhotoUrl != null
                      ? Image.network(
                          ApiUrl.imageUrl(core.testPhotoUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              // Test Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              core.testName,
                              style: AppTextStyles.cardTitle.copyWith(
                                fontSize: 17,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildPriceTag(),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labName,
                        style: AppTextStyles.tagline.copyWith(
                          fontSize: 10,
                          color: AppColors.primaryAccent,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip(Iconsax.category, core.testCategory),
                          _buildChip(Iconsax.colors_square, core.sampleType),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Arrow Indicator
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.arrow_right_3_copy,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(Iconsax.microphone, color: AppColors.primary, size: 32),
    );
  }

  Widget _buildPriceTag() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '₹${test.marketPrice.toStringAsFixed(0)}',
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: 16,
            color: AppColors.primaryAccent,
          ),
        ),
        if (test.discountPercent > 0)
          Text(
            '₹${test.price.toStringAsFixed(0)}',
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
