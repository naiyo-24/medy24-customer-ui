import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../theme/app_theme.dart';

class SavedAddressCard extends StatelessWidget {
  final Map<String, dynamic> address;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const SavedAddressCard({
    super.key,
    required this.address,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.location,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address['address_1'] ?? 'Home',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address['street_address'] ?? 'N/A',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Iconsax.trash,
                  size: 20,
                  color: AppColors.error,
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
