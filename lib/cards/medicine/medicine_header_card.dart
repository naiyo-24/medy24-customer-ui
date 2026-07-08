import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/medicine.dart';
import '../../theme/app_theme.dart';

import 'package:go_router/go_router.dart';

class MedicineHeaderCard extends StatelessWidget {
  final MedicineModel medicine;
  final GlobalKey imageKey;

  const MedicineHeaderCard({super.key, required this.medicine, required this.imageKey});

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = medicine.isActive == false;
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height * 0.45,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Container(
              key: imageKey,
              child: Image.asset(
                'assets/logo/demo_med_image.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Gradient Overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(100),
                    Colors.transparent,
                    Colors.black.withAlpha(180),
                  ],
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.arrow_left_1, color: Colors.white),
              ),
            ),
          ),

          // Medicine Info at Bottom
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    medicine.medicineCategory?.toUpperCase() ?? 'GENERAL',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  medicine.medicineName ?? 'Medicine Name',
                  style: AppTextStyles.header.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      medicine.medicineQuantity ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isOutOfStock ? AppColors.error : Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isOutOfStock ? 'OUT OF STOCK' : 'IN STOCK',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${medicine.finalPrice?.toStringAsFixed(0) ?? '0'}',
                      style: AppTextStyles.header.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (medicine.discountPercent != null &&
                        medicine.discountPercent! > 0) ...[
                      Text(
                        '₹${medicine.mrp?.toStringAsFixed(0) ?? '0'}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 18,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${medicine.discountPercent!.toInt()}% OFF',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
