import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LabTestCategoriesRow extends StatelessWidget {
  final Function(String) onCategoryTap;

  const LabTestCategoriesRow({
    super.key,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'Full Body\nCheckup', 'icon': Icons.bloodtype, 'color': Colors.red},
      {'title': 'Heart\nHealth', 'icon': Icons.monitor_heart, 'color': Colors.redAccent},
      {'title': 'Diabetes\nCare', 'icon': Icons.water_drop, 'color': Colors.lightBlue},
      {'title': 'Liver\nFunction', 'icon': Icons.healing, 'color': Colors.deepOrange}, 
      {'title': 'Kidney\nFunction', 'icon': Icons.spa_outlined, 'color': Colors.orange}, 
      {'title': 'Thyroid\nTests', 'icon': Icons.coronavirus_outlined, 'color': Colors.pink}, 
      {'title': 'Immunity &\nVitamins', 'icon': Icons.shield_outlined, 'color': Colors.teal},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.map((cat) {
          return GestureDetector(
            onTap: () => onCategoryTap(cat['title'] as String),
            child: Container(
              width: 72,
              margin: const EdgeInsets.only(right: 12.0),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.withAlpha(20), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      cat['icon'] as IconData,
                      color: cat['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['title'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
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
