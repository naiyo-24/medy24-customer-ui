import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../theme/app_theme.dart';

class RetailerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const RetailerBottomNavBar({
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
                icon: Iconsax.truck_fast,
                activeIcon: Iconsax.truck_fast,
                label: 'Live Orders',
                isActive: currentIndex == 0,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(0);
                },
              ),
              _NavBarItem(
                icon: Iconsax.shop,
                activeIcon: Iconsax.shop,
                label: 'Wholesale',
                isActive: currentIndex == 1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(1);
                },
              ),
              _NavBarItem(
                icon: Iconsax.chart_2,
                activeIcon: Iconsax.chart_2,
                label: 'Earnings',
                isActive: currentIndex == 2,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(2);
                },
              ),
              _NavBarItem(
                icon: Iconsax.verify,
                activeIcon: Iconsax.verify,
                label: 'Compliance',
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
