import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/global_lab_test.dart';

class HealthPackagesHorizontalList extends StatelessWidget {
  final Function(GlobalLabTest) onBookTap;

  const HealthPackagesHorizontalList({
    super.key,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    final packages = [
      {
        'id': 'TEST-PKG-0001',
        'name': 'Medy Essential Full Body Checkup',
        'tests': '45+ Tests',
        'badge': 'Most Booked',
        'badgeColor': Colors.tealAccent.shade700,
        'imageBgColor': const Color(0xFFE5FAFA),
        'icon': Icons.family_restroom,
        'iconColor': Colors.teal,
      },
      {
        'id': 'TEST-PKG-0002',
        'name': 'Medy Advanced Heart Care',
        'tests': '18+ Tests',
        'badge': 'Popular',
        'badgeColor': Colors.blueAccent,
        'imageBgColor': const Color(0xFFE3F2FD),
        'icon': Icons.monitor_heart,
        'iconColor': Colors.redAccent,
      },
      {
        'id': 'TEST-PKG-0004',
        'name': 'Medy Diabetic Care & Monitoring',
        'tests': '12+ Tests',
        'badge': 'Essential',
        'badgeColor': Colors.purpleAccent,
        'imageBgColor': const Color(0xFFF3E5F5),
        'icon': Icons.water_drop,
        'iconColor': Colors.blue,
      },
      {
        'id': 'TEST-PKG-0003',
        'name': 'Medy Women\'s Comprehensive Health',
        'tests': '32+ Tests',
        'badge': 'Best Value',
        'badgeColor': Colors.pinkAccent,
        'imageBgColor': const Color(0xFFFCE4EC),
        'icon': Icons.woman,
        'iconColor': Colors.pink,
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
          final testObj = GlobalLabTest(
            testId: pkg['id'] as String,
            testName: pkg['name'] as String,
            category: 'Medy Global Packages',
            description: '',
            isProfile: true,
            numberOfParameters: int.parse((pkg['tests'] as String).split('+')[0]),
            sampleType: 'Blood',
            searchTags: '',
            fastingRequired: true,
            fastingHours: '10-12 hours',
            preTestInfo: '',
          );

          return GestureDetector(
            onTap: () => onBookTap(testObj),
            child: Container(
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
                      const Text(
                        'Prices vary',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textTertiary,
                        ),
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
                          onPressed: () => onBookTap(testObj),
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
            ),
          );
        },
      ),
    );
  }
}
