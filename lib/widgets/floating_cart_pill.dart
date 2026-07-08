import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:add_to_cart_animation/add_to_cart_animation.dart';

import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../services/cart_animation_service.dart';

class FloatingCartPill extends ConsumerWidget {
  const FloatingCartPill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    if (cartState.items.isEmpty) {
      return const SizedBox.shrink();
    }

    // Limit to 3 images to avoid overflow
    final imagesToShow = cartState.items.take(3).toList();
    final totalItems = cartState.items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Positioned(
      bottom: 20,
      left: 32,
      right: 32,
      child: GestureDetector(
        onTap: () => context.push('/cart'),
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
                            image: const AssetImage('assets/logo/demo_med_image.png'), // Replace with network image if available
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
                child: AddToCartIcon(
                  key: CartAnimationService.cartKey,
                  badgeOptions: const BadgeOptions(active: false),
                  icon: const Icon(
                    Iconsax.arrow_right_3,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ).animate().slideY(begin: 1.0, end: 0, duration: 300.ms, curve: Curves.easeOutCubic).fadeIn(),
      ),
    );
  }
}
