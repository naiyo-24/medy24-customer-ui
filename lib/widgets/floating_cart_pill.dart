import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../routes/app_router.dart';

class FloatingCartPill extends ConsumerWidget {
  const FloatingCartPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    final isEmpty = cartState.items.isEmpty;

    // Limit to 3 images to avoid overflow
    final imagesToShow = cartState.items.take(3).toList();
    final totalItems = cartState.items.fold<int>(0, (sum, item) => sum + item.quantity);

    // Use a static Positioned so the CartIconKey is ALWAYS at the exact final coordinate (bottom: 90).
    // This ensures the very first animated item flies to the correct spot instead of flying off-screen.
    // We animate its appearance using AnimatedOpacity and AnimatedScale.
    // We animate its appearance using AnimatedOpacity and AnimatedScale.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isEmpty ? 0.0 : 1.0,
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: isEmpty ? 0.8 : 1.0,
          curve: Curves.easeOutBack,
          child: IgnorePointer(
          ignoring: isEmpty,
          child: GestureDetector(
            onTap: () => appRouter.go('/cart'),
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side: Overlapping item images
                  SizedBox(
                    width: 80,
                    height: 40,
                    child: Stack(
                      children: List.generate(imagesToShow.length, (index) {
                        return Positioned(
                          left: index * 20.0,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              color: Colors.white,
                              image: DecorationImage(
                                image: const AssetImage('assets/logo/demo_med_image.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Center: Cart summary text
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'View cart',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$totalItems item${totalItems > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side: Arrow in darker circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.darkCyan,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.arrow_right_3,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
}
