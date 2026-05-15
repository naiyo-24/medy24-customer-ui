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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      decoration: BoxDecoration(color: AppColors.background.withAlpha(200)),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Row(
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
                            // Fallback if there's nothing to pop
                            context.go('/home');
                          }
                        },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Iconsax.arrow_left_2,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  )
                else if (showLogo)
                  Container(
                    height: 40,
                    width: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
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
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),

                // Actions Section
                if (actions != null)
                  IconTheme(
                    data: const IconThemeData(color: AppColors.primary),
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
