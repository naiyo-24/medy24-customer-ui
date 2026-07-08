import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../theme/app_theme.dart';

class HealthTipsWidget extends StatelessWidget {
  const HealthTipsWidget({super.key});

  static const List<Map<String, dynamic>> _tips = [
    {
      'icon': Iconsax.drop,
      'tip': 'Stay hydrated! Drink at least 8 glasses of water daily.',
      'color': Color(0xFF3B82F6),
    },
    {
      'icon': Iconsax.sun_1,
      'tip': 'Get 7–8 hours of sleep for optimal health & immunity.',
      'color': Color(0xFFF59E0B),
    },
    {
      'icon': Iconsax.heart,
      'tip': 'Regular health checkups can detect problems early.',
      'color': Color(0xFFEF4444),
    },
    {
      'icon': Iconsax.health,
      'tip': 'Take your prescribed medicines on time, every day.',
      'color': Color(0xFF10B981),
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Rotate based on time of day
    final tipIndex = DateTime.now().hour % _tips.length;
    final tip = _tips[tipIndex];
    final color = tip['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(40), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tip['icon'] as IconData,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Tip of the Hour',
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip['tip'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideY(begin: 0.15, end: 0);
  }
}
