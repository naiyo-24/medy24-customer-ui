import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PopularBrandsRow extends StatelessWidget {
  final Function(String) onBrandTap;

  const PopularBrandsRow({
    super.key,
    required this.onBrandTap,
  });

  @override
  Widget build(BuildContext context) {
    final brands = [
      {'name': 'Cipla', 'discount': 'Upto 20% OFF', 'color': Colors.blue},
      {'name': 'Sun Pharma', 'discount': 'Upto 20% OFF', 'color': Colors.orange},
      {'name': 'Abbott', 'discount': 'Upto 15% OFF', 'color': Colors.lightBlue},
      {'name': 'Dr. Reddy\'s', 'discount': 'Upto 15% OFF', 'color': Colors.deepPurple},
      {'name': 'Zydus', 'discount': 'Upto 15% OFF', 'color': Colors.indigo},
      {'name': 'Lupin', 'discount': 'Upto 10% OFF', 'color': Colors.green},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: brands.map((brand) {
          return GestureDetector(
            onTap: () => onBrandTap(brand['name'] as String),
            child: Container(
              width: 110,
              margin: const EdgeInsets.only(right: 12.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withAlpha(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder for Brand Logo
                  Icon(
                    Icons.business,
                    color: brand['color'] as Color,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    brand['name'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    brand['discount'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryAccent, 
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
