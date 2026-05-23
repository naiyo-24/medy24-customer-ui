import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final bool showLogo;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackTap;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.showLogo = false,
    this.showBackButton = false,
    this.actions,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(240),
        border: const Border(
          bottom: BorderSide(color: AppColors.divider, width: 1.0),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Leading Section: Logo or Back Button
                  if (showBackButton)
                    GestureDetector(
                      onTap:
                          onBackTap ??
                          () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: const Icon(
                          Iconsax.arrow_left_2,
                          size: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )
                  else if (showLogo)
                    Container(
                      height: 38,
                      width: 38,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Image.asset(
                        'assets/logo/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                  const SizedBox(width: 12),

                  // Title and Subtitle Section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: AppTextStyles.subHeader.copyWith(
                              fontSize: 18,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Actions Section
                  if (actions != null)
                    IconTheme(
                      data: const IconThemeData(
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!
                            .map(
                              (action) => Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: action,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(66);
}
