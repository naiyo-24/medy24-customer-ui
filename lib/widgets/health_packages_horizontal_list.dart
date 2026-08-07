import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HealthPackagesHorizontalList extends StatelessWidget {
  final Function(String) onBookTap;

  const HealthPackagesHorizontalList({
    super.key,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    final packages = [
      {
        'name': 'Smart Full Body\nCheckup',
        'tests': '80+ Tests',
        'price': '₹999',
        'originalPrice': '₹1,399',
        'badge': 'Most Booked',
        'badgeColor': Colors.tealAccent.shade700,
        'imageBgColor': const Color(0xFFE5FAFA),
        'icon': Icons.family_restroom,
        'iconColor': Colors.teal,
      },
      {
        'name': 'Heart Care\nPackage',
        'tests': '50+ Tests',
        'price': '₹799',
        'originalPrice': '₹1,199',
        'badge': 'Popular',
        'badgeColor': Colors.blueAccent,
        'imageBgColor': const Color(0xFFE3F2FD),
        'icon': Icons.monitor_heart,
        'iconColor': Colors.redAccent,
      },
      {
        'name': 'Liver Function\nPackage',
        'tests': '30+ Tests',
        'price': '₹599',
        'originalPrice': '₹899',
        'badge': 'Best Value',
        'badgeColor': Colors.orangeAccent,
        'imageBgColor': const Color(0xFFFFF3E0),
        'icon': Icons.healing,
        'iconColor': Colors.deepOrange,
      },
      {
        'name': 'Diabetes\nCheckup',
        'tests': '40+ Tests',
        'price': '₹699',
        'originalPrice': '₹899',
        'badge': 'Essential',
        'badgeColor': Colors.purpleAccent,
        'imageBgColor': const Color(0xFFF3E5F5),
        'icon': Icons.water_drop,
        'iconColor': Colors.blue,
      },
    ];

    return SizedBox(
      height: 290,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final pkg = packages[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withAlpha(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section with background and badge
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: pkg['imageBgColor'] as Color,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          pkg['icon'] as IconData,
                          size: 48,
                          color: pkg['iconColor'] as Color,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: pkg['badgeColor'] as Color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pkg['badge'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pkg['name'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pkg['tests'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            pkg['price'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            pkg['originalPrice'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Free Home Collection',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: () => onBookTap(pkg['name'] as String),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
