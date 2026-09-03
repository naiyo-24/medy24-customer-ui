import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/featured_package.dart';
import '../models/global_lab_test.dart';

class HealthPackagesHorizontalList extends StatelessWidget {
  final List<FeaturedPackage> packages;
  final Function(GlobalLabTest) onBookTap;

  const HealthPackagesHorizontalList({
    super.key,
    required this.packages,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 290,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final pkg = packages[index];
          
          // Generate a dynamic UI mapping based on index
          final badgeColors = [Colors.tealAccent.shade700, Colors.blueAccent, Colors.purpleAccent, Colors.pinkAccent];
          final bgColors = [const Color(0xFFE5FAFA), const Color(0xFFE3F2FD), const Color(0xFFF3E5F5), const Color(0xFFFCE4EC)];
          final iconColors = [Colors.teal, Colors.redAccent, Colors.blue, Colors.pink];
          final icons = [Icons.family_restroom, Icons.monitor_heart, Icons.water_drop, Icons.woman];
          final badges = ['Most Booked', 'Popular', 'Essential', 'Best Value'];
          
          final colorIdx = index % badgeColors.length;

          final testObj = GlobalLabTest(
            testId: pkg.testId,
            testName: pkg.testName,
            category: pkg.category,
            description: '',
            isProfile: true,
            numberOfParameters: pkg.numberOfParameters,
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
                    color: bgColors[colorIdx],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          icons[colorIdx],
                          size: 48,
                          color: iconColors[colorIdx],
                        ),
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColors[colorIdx],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badges[colorIdx],
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
                        pkg.testName,
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
                        '${pkg.numberOfParameters}+ Tests',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Starts at ₹${pkg.startingPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
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
