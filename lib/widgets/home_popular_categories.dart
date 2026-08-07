import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomePopularCategories extends StatelessWidget {
  const HomePopularCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'Diabetes\nCare', 'icon': Icons.bloodtype, 'color': Colors.blueGrey},
      {'title': 'Heart\nCare', 'icon': Icons.favorite, 'color': Colors.red},
      {'title': 'Pain\nRelief', 'icon': Icons.healing, 'color': Colors.teal},
      {'title': 'Baby\nCare', 'icon': Icons.child_care, 'color': Colors.pinkAccent},
      {'title': 'Personal\nCare', 'icon': Icons.clean_hands, 'color': Colors.indigo},
      {'title': 'Nutrition\n& Health', 'icon': Icons.eco, 'color': Colors.green},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Categories',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100, // Fixed height for horizontal list
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return SizedBox(
                width: 60,
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF2F4F7), // Light grey matching design
                      ),
                      child: Center(
                        child: Icon(
                          cat['icon'] as IconData,
                          color: cat['color'] as Color,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
