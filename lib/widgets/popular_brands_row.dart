import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PopularBrandsRow extends StatelessWidget {
  final List<String> brands;
  final Function(String) onBrandTap;

  const PopularBrandsRow({
    super.key,
    required this.brands,
    required this.onBrandTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.lightBlue,
      Colors.deepPurple,
      Colors.indigo,
      Colors.green,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: brands.asMap().entries.map((entry) {
          final index = entry.key;
          final brandName = entry.value;
          final color = colors[index % colors.length];

          return GestureDetector(
            onTap: () => onBrandTap(brandName),
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
                    color: color,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    brandName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
