import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HealthConcernItem {
  final String title;
  final Color bgColor;
  final String imagePath;
  final VoidCallback onTap;

  const HealthConcernItem({
    required this.title,
    required this.bgColor,
    required this.imagePath,
    required this.onTap,
  });
}

/// "LAB TESTS BY HEALTH CONCERN" grid — colored cards with title + image
class HealthConcernGrid extends StatelessWidget {
  final List<HealthConcernItem> items;

  const HealthConcernGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Expanded(child: Container(height: 1, color: AppColors.divider)),
              const SizedBox(width: 10),
              Text(
                'LAB TESTS BY HEALTH CONCERN',
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 1, color: AppColors.divider)),
            ],
          ),

          const SizedBox(height: 14),

          // 3-column grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _HealthConcernCard(item: items[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _HealthConcernCard extends StatefulWidget {
  final HealthConcernItem item;

  const _HealthConcernCard({required this.item});

  @override
  State<_HealthConcernCard> createState() => _HealthConcernCardState();
}

class _HealthConcernCardState extends State<_HealthConcernCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.item.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: widget.item.bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title (bold, dark)
              Text(
                widget.item.title,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                maxLines: 2,
              ),
              const Spacer(),
              // Image bottom-right aligned
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  height: 44,
                  width: 44,
                  child: Image.asset(
                    widget.item.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(100),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.science_outlined,
                        size: 24,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
