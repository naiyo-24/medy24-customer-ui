import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeSecondaryBanner extends StatelessWidget {
  const HomeSecondaryBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFE5F6FA), // Light cyan background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Scooter Icon placeholder
            const Icon(
              Icons.electric_scooter,
              size: 40,
              color: AppColors.primaryAccent,
            ),
            const SizedBox(width: 12),
            // Text Content
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FREE Delivery 🚚',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'On orders above ₹499',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            // Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Text(
                    'Shop Now',
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
