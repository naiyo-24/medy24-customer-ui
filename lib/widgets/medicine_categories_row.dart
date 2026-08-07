import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MedicineCategoriesRow extends StatelessWidget {
  final Function(String) onCategoryTap;

  const MedicineCategoriesRow({
    super.key,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'Fever', 'icon': Icons.medical_services_outlined, 'color': Colors.blue},
      {'title': 'Cold & Flu', 'icon': Icons.sick_outlined, 'color': Colors.indigo},
      {'title': 'Diabetes', 'icon': Icons.water_drop_outlined, 'color': Colors.lightBlue},
      {'title': 'Heart Care', 'icon': Icons.favorite_border, 'color': Colors.red},
      {'title': 'Pain Relief', 'icon': Icons.accessibility_new_outlined, 'color': Colors.teal},
      {'title': 'Skin Care', 'icon': Icons.face_retouching_natural, 'color': Colors.orange},
      {'title': 'Baby Care', 'icon': Icons.child_care, 'color': Colors.pink},
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
