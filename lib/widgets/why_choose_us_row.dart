import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WhyChooseUsRow extends StatelessWidget {
  const WhyChooseUsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      {
        'title': 'Free Home\nCollection',
        'subtitle': 'Safe & hygienic\nsample pickup',
        'icon': Icons.home_outlined,
        'iconColor': Colors.teal,
      },
      {
        'title': 'Trusted Labs\n& Accurate',
        'subtitle': 'NABL accredited\nlabs',
        'icon': Icons.verified_outlined,
        'iconColor': Colors.blue,
      },
      {
        'title': 'Quick Reports',
        'subtitle': 'Reports within\n24-48 hours',
        'icon': Icons.description_outlined,
        'iconColor': Colors.blueGrey,
      },
      {
        'title': 'Secure &\nConfidential',
        'subtitle': 'Your data is\n100% safe',
        'icon': Icons.lock_outline,
        'iconColor': Colors.lightBlue,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: benefits.map((benefit) {
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withAlpha(30)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  benefit['icon'] as IconData,
                  color: benefit['iconColor'] as Color,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit['title'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        benefit['subtitle'] as String,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
