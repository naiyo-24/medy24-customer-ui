import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.divider, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Iconsax.home_1,
                activeIcon: Iconsax.home_1,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(0);
                },
              ),
              _NavBarItem(
                icon: Iconsax.health,
                activeIcon: Iconsax.health,
                label: 'Meds',
                isActive: currentIndex == 1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(1);
                },
              ),
              _NavBarItem(
                icon: Iconsax.microscope,
                activeIcon: Iconsax.microscope,
                label: 'Tests',
                isActive: currentIndex == 2,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(2);
                },
              ),
              _NavBarItem(
                icon: Iconsax.hospital_copy,
                activeIcon: Iconsax.hospital,
                label: 'Labs',
                isActive: currentIndex == 3,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(3);
                },
              ),
            ],
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
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isActive ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
