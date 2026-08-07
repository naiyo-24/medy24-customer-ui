import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeCategoryIcons extends StatelessWidget {
  final Function(int) onCategoryTap;

  const HomeCategoryIcons({super.key, required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'Medicines', 'icon': Icons.medication, 'color': Colors.blue},
      {'title': 'Lab Tests', 'icon': Icons.science, 'color': Colors.indigo},
      {'title': 'Doctor\nConsultation', 'icon': Icons.person, 'color': Colors.teal},
      {'title': 'Upload\nPrescription', 'icon': Icons.camera_alt, 'color': Colors.blueGrey},
      {'title': 'Wellness', 'icon': Icons.favorite, 'color': Colors.redAccent},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(categories.length, (index) {
          final cat = categories[index];
          return Expanded(
            child: GestureDetector(
              onTap: () => onCategoryTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        cat['icon'] as IconData,
                        size: 28,
                        color: cat['color'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
