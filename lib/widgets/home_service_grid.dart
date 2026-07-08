import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeServiceGridItem {
  final String title;
  final String subtitle;
  final String offerText;
  final Color offerColor;
  final String imagePath;
  final VoidCallback onTap;

  const HomeServiceGridItem({
    required this.title,
    required this.subtitle,
    required this.offerText,
    required this.offerColor,
    required this.imagePath,
    required this.onTap,
  });
}

/// 2×2 grid of service cards like Apollo Pharmacy home screen.
class HomeServiceGrid extends StatelessWidget {
  final List<HomeServiceGridItem> items;

  const HomeServiceGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    // Ensure we have at most 4 items for 2×2 layout
    final displayItems = items.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          Row(
            children: [
              if (displayItems.isNotEmpty)
                Expanded(child: _ServiceCard(item: displayItems[0])),
              const SizedBox(width: 10),
              if (displayItems.length > 1)
                Expanded(child: _ServiceCard(item: displayItems[1]))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (displayItems.length > 2)
                Expanded(child: _ServiceCard(item: displayItems[2]))
              else
                const Expanded(child: SizedBox()),
              const SizedBox(width: 10),
              if (displayItems.length > 3)
                Expanded(child: _ServiceCard(item: displayItems[3]))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final HomeServiceGridItem item;

  const _ServiceCard({required this.item});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
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
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with arrow
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.title,
                      style: const TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Offer text
              Text(
                widget.item.offerText,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.item.offerColor,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 4),

              // Subtitle
              Text(
                widget.item.subtitle,
                style: const TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 12),

              // Image
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  height: 72,
                  child: Image.asset(
                    widget.item.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.medical_services_outlined,
                      size: 40,
                      color: widget.item.offerColor.withAlpha(150),
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
