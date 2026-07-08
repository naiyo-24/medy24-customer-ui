import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HomeCategoryTab {
  final String label;
  final IconData? icon;
  final String? badge;
  final Color? badgeColor;

  const HomeCategoryTab({
    required this.label,
    this.icon,
    this.badge,
    this.badgeColor,
  });
}

class HomeCategoryTabs extends StatefulWidget {
  final List<HomeCategoryTab> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const HomeCategoryTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  State<HomeCategoryTabs> createState() => _HomeCategoryTabsState();
}

class _HomeCategoryTabsState extends State<HomeCategoryTabs> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(height: 1, color: AppColors.divider),
          SizedBox(
            height: 56, // Slightly increased from 50
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.tabs.length,
              itemBuilder: (context, index) {
                final tab = widget.tabs[index];
                final isSelected = widget.selectedIndex == index;
                return GestureDetector(
                  onTap: () => widget.onTabSelected(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (tab.icon != null) ...[
                                  Icon(
                                    tab.icon,
                                    size: 18,
                                    color: isSelected
                                        ? AppColors.primaryAccent
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  tab.label,
                                  style: TextStyle(
                                    fontFamily: 'Lexend',
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? AppColors.primaryAccent
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            if (tab.badge != null)
                              Positioned(
                                top: -6,
                                right: -10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tab.badgeColor ?? AppColors.error,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tab.badge!,
                                    style: const TextStyle(
                                      fontFamily: 'Lexend',
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Active bottom line indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 3, 
                          width: isSelected ? 60 : 0, // Increased to span properly
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent,
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
        ],
      ),
    );
  }
}
