import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TopHealthTestsList extends StatelessWidget {
  final Function(String) onAddTap;

  const TopHealthTestsList({
    super.key,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final tests = [
      {
        'title': 'Complete Blood Count (CBC)',
        'subtitle': 'Measures overall health',
        'price': '₹199',
        'originalPrice': '₹299',
        'icon': Icons.bloodtype,
        'iconColor': Colors.red,
      },
      {
        'title': 'HbA1c Test',
        'subtitle': 'Average blood sugar (3 months)',
        'price': '₹299',
        'originalPrice': '₹450',
        'icon': Icons.water_drop,
        'iconColor': Colors.blue,
      },
      {
        'title': 'Liver Function Test (LFT)',
        'subtitle': 'Liver health & function',
        'price': '₹399',
        'originalPrice': '₹600',
        'icon': Icons.healing,
        'iconColor': Colors.deepOrange,
      },
      {
        'title': 'Thyroid Profile (T3, T4, TSH)',
        'subtitle': 'Thyroid health check',
        'price': '₹499',
        'originalPrice': '₹700',
        'icon': Icons.coronavirus_outlined,
        'iconColor': Colors.pink,
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final test = tests[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withAlpha(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  test['icon'] as IconData,
                  color: test['iconColor'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      test['title'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      test['subtitle'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        test['price'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        test['originalPrice'] as String,
                        style: const TextStyle(
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 28,
                    child: ElevatedButton(
                      onPressed: () => onAddTap(test['title'] as String),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.add_circle, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
