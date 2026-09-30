import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Image.asset(
                'assets/logo/medy24logo.png',
                height: 120,
              ).animate().fadeIn(duration: 600.ms).scale(curve: Curves.easeOutBack),
              const SizedBox(height: 32),
              Text(
                'Choose Your Role',
                style: AppTextStyles.header.copyWith(fontSize: 28),
              ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
              const SizedBox(height: 8),
              Text(
                'Select how you want to use Medy24',
                style: AppTextStyles.description,
              ).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0),
              const Spacer(flex: 2),
              
              _buildRoleCard(
                context: context,
                title: 'Customer',
                description: 'Order medicines & book lab tests',
                icon: Iconsax.user,
                color: AppColors.primary,
                route: '/login',
                delay: 400,
              ),
              const SizedBox(height: 16),
              
              _buildRoleCard(
                context: context,
                title: 'Pharmacy / Retailer',
                description: 'Manage shop, inventory & buy wholesale',
                icon: Iconsax.shop,
                color: Colors.blue,
                route: '/retailer-login',
                delay: 500,
              ),
              const SizedBox(height: 16),
              
              _buildRoleCard(
                context: context,
                title: 'Wholesale Distributor',
                description: 'Manage inventory & fulfill retailer orders',
                icon: Iconsax.truck_fast,
                color: Colors.orange,
                route: '/distributor-login',
                delay: 600,
              ),
              
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
    required int delay,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
          border: Border.all(color: color.withAlpha(50), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 4),
                  Text(description, style: AppTextStyles.caption),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.textTertiary, size: 16),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}
