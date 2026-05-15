import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(20),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(
                color: Colors.white.withAlpha(120),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavBarItem(
                  icon: Iconsax.home_1,
                  activeIcon: Iconsax.home_1,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (currentIndex != 0) context.go('/home');
                  },
                ),
                _NavBarItem(
                  icon: Iconsax.health,
                  activeIcon: Iconsax.health,
                  label: 'Meds',
                  isActive: currentIndex == 1,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (currentIndex != 1) context.go('/medicine-list');
                  },
                ),
                _NavBarItem(
                  icon: Iconsax.microscope,
                  activeIcon: Iconsax.microscope,
                  label: 'Tests',
                  isActive: currentIndex == 2,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (currentIndex != 2) context.go('/lab-test-list');
                  },
                ),
                _NavBarItem(
                  icon: Iconsax.hospital,
                  activeIcon: Iconsax.hospital,
                  label: 'Labs',
                  isActive: currentIndex == 3,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    if (currentIndex != 3) context.go('/patho-lab-list');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              padding: EdgeInsets.symmetric(
                horizontal: isActive ? 12 : 8,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withAlpha(180),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(100),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? activeIcon : icon,
                      color: isActive ? Colors.white : AppColors.textTertiary,
                      size: 20,
                    ),
                    AnimatedClipRect(
                      open: isActive,
                      horizontalAnimation: true,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          softWrap: false,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              width: isActive ? 4 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(200),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A helper widget to animate the clipping of a child widget.
class AnimatedClipRect extends StatelessWidget {
  final Widget child;
  final bool open;
  final bool horizontalAnimation;
  final Duration duration;

  const AnimatedClipRect({
    super.key,
    required this.child,
    required this.open,
    this.horizontalAnimation = true,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: Curves.easeInOutQuart,
      tween: Tween(begin: 0.0, end: open ? 1.0 : 0.0),
      builder: (context, value, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            heightFactor: horizontalAnimation ? 1.0 : value,
            widthFactor: horizontalAnimation ? value : 1.0,
            child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
          ),
        );
      },
      child: child,
    );
  }
}
