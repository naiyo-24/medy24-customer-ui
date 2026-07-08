import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/medicine.dart';
import '../../theme/app_theme.dart';


class MedicineSearchCard extends StatelessWidget {
  final MedicineModel medicine;
  final VoidCallback onTap;

  const MedicineSearchCard({
    super.key,
    required this.medicine,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = medicine.isActive == false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Medicine Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: AppColors.divider,
                child: Image.asset(
                  'assets/logo/demo_med_image.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Info Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.medicineName ?? 'Medicine Name',
                    style: AppTextStyles.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicine.medicineCategory ?? '',
                    style: AppTextStyles.cardSubtitle.copyWith(
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '₹${medicine.finalPrice?.toStringAsFixed(0) ?? '0'}',
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        medicine.medicineQuantity ?? '',
                        style: AppTextStyles.cardSubtitle,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stock Status
            Column(
              children: [
                Icon(
                  isOutOfStock ? Iconsax.close_circle : Iconsax.tick_circle,
                  color: isOutOfStock ? AppColors.error : Colors.green,
                ),
                const SizedBox(height: 4),
                Text(
                  isOutOfStock ? 'OUT' : 'IN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isOutOfStock ? AppColors.error : Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
