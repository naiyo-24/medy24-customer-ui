import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LabTestCategoriesRow extends StatelessWidget {
  final List<String> categories;
  final Function(String) onCategoryTap;

  const LabTestCategoriesRow({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final styles = [
      {'icon': Icons.bloodtype, 'color': Colors.red},
      {'icon': Icons.monitor_heart, 'color': Colors.redAccent},
      {'icon': Icons.water_drop, 'color': Colors.lightBlue},
      {'icon': Icons.healing, 'color': Colors.deepOrange}, 
      {'icon': Icons.spa_outlined, 'color': Colors.orange}, 
      {'icon': Icons.coronavirus_outlined, 'color': Colors.pink}, 
      {'icon': Icons.shield_outlined, 'color': Colors.teal},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categories.asMap().entries.map((entry) {
          final index = entry.key;
          final categoryTitle = entry.value;
          final style = styles[index % styles.length];

          return GestureDetector(
            onTap: () => onCategoryTap(categoryTitle),
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
                      style['icon'] as IconData,
                      color: style['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categoryTitle,
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
