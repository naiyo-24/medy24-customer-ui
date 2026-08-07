import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeServiceGridItem {
  final String title;
  final String subtitle;
  final String offerText;
  final Color offerColor;
  final Color bgColor;
  final String imagePath;
  final VoidCallback onTap;

  const HomeServiceGridItem({
    required this.title,
    required this.subtitle,
    required this.offerText,
    required this.offerColor,
    required this.bgColor,
    required this.imagePath,
    required this.onTap,
  });
}

class HomeServiceGrid extends StatelessWidget {
  final List<HomeServiceGridItem> items;

  const HomeServiceGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final displayItems = items.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              if (displayItems.isNotEmpty)
                Expanded(child: _ServiceCard(item: displayItems[0])),
              const SizedBox(width: 12),
              if (displayItems.length > 1)
                Expanded(child: _ServiceCard(item: displayItems[1]))
              else
                const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (displayItems.length > 2)
                Expanded(child: _ServiceCard(item: displayItems[2]))
              else
                const Expanded(child: SizedBox()),
              const SizedBox(width: 12),
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
          height: 140, // Fixed height for consistency
          padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
          decoration: BoxDecoration(
            color: widget.item.bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.subtitle,
                    style: const TextStyle(
                      fontFamily: 'Lexend',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.item.offerText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.item.offerColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        widget.item.offerText,
                        style: TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: widget.item.offerColor,
                        ),
                      ),
                    ),
                ],
              ),
              
              // Arrow Icon (Top Right)
              Positioned(
                top: 0,
                right: 12,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                ),
              ),

              // Image (Bottom Right)
              Positioned(
                bottom: 0,
                right: 8,
                child: Image.asset(
                  widget.item.imagePath,
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(width: 60, height: 60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
