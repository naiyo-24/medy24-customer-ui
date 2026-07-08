import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The search bar styled like Apollo/1mg — flat white pill with camera icon.
class HomeSearchInput extends StatefulWidget {
  final VoidCallback? onTap;
  final Function(String)? onChanged;

  const HomeSearchInput({super.key, this.onTap, this.onChanged});

  @override
  State<HomeSearchInput> createState() => _HomeSearchInputState();
}

class _HomeSearchInputState extends State<HomeSearchInput> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: _isFocused ? AppColors.primary : AppColors.divider,
            width: _isFocused ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Focus(
          onFocusChange: (v) => setState(() => _isFocused = v),
          child: TextField(
            onTap: widget.onTap,
            onChanged: widget.onChanged,
            style: const TextStyle(
              fontFamily: 'Lexend',
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 13,
                horizontal: 0,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textTertiary,
                size: 22,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rx (Prescription) Icon
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  // Camera Icon
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              hintText: 'Search medicines & lab tests...',
              hintStyle: TextStyle(
                fontFamily: 'Lexend',
                fontSize: 13,
                color: AppColors.textTertiary.withAlpha(180),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
