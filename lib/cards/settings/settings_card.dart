import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool showTrailing;

  const SettingsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.showTrailing = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppCardStyles.sleekCard,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
          ),
          title: Text(
            title,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: showTrailing
              ? Icon(
                  Icons.arrow_right,
                  size: 18,
                  color: AppColors.textTertiary.withAlpha(150),
                )
              : null,
        ),
      ),
    );
  }
}
