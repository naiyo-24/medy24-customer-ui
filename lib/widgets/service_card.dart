import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../theme/app_theme.dart';

/// A premium service card used on the home screen for each service category.
class ServiceCard extends StatefulWidget {
  final String badge;
  final String title;
  final String description;
  final String buttonLabel;
  final String? imagePath;
  final IconData? fallbackIcon;
  final Color accentColor;
  final VoidCallback onTap;
  final bool imageOnLeft;
  final int animationDelay;

  const ServiceCard({
    super.key,
    required this.badge,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.accentColor,
    required this.onTap,
    this.imagePath,
    this.fallbackIcon,
    this.imageOnLeft = false,
    this.animationDelay = 0,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _isPressed = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isPressed
                  ? widget.accentColor.withAlpha(80)
                  : AppColors.divider.withAlpha(120),
              width: _isPressed ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? widget.accentColor.withAlpha(30)
                    : Colors.black.withAlpha(8),
                blurRadius: _isPressed ? 20 : 12,
                offset: const Offset(0, 6),
                spreadRadius: _isPressed ? 2 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Subtle top accent line
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.accentColor.withAlpha(80),
                          widget.accentColor,
                          widget.accentColor.withAlpha(80),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                  child: widget.imageOnLeft
                      ? _buildImageLeft()
                      : _buildImageRight(),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 500.ms,
          delay: Duration(milliseconds: widget.animationDelay),
        )
        .slideY(begin: 0.15, end: 0);
  }

  Widget _buildImageRight() {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildTextContent()),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: _buildImage()),
      ],
    );
  }

  Widget _buildImageLeft() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildImage()),
        const SizedBox(width: 12),
        Expanded(flex: 3, child: _buildTextContent()),
      ],
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: widget.accentColor.withAlpha(18),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: widget.accentColor.withAlpha(40),
              width: 1,
            ),
          ),
          child: Text(
            widget.badge,
            style: TextStyle(
              fontFamily: 'Lexend',
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: widget.accentColor,
              letterSpacing: 1.5,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Title
        Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Fraunces',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.15,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 6),

        // Description
        Text(
          widget.description,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
            height: 1.4,
          ),
        ),

        const SizedBox(height: 16),

        // CTA Button
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: widget.accentColor,
              borderRadius: BorderRadius.circular(100),
              boxShadow: [
                BoxShadow(
                  color: widget.accentColor.withAlpha(80),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.buttonLabel,
                  style: const TextStyle(
                    fontFamily: 'Lexend',
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Iconsax.arrow_right_1,
                  color: Colors.white,
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (widget.imagePath != null) {
      return Image.asset(
        widget.imagePath!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    }
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: widget.accentColor.withAlpha(15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.fallbackIcon ?? Icons.medical_services_outlined,
          color: widget.accentColor,
          size: 40,
        ),
      ),
    );
  }
}
