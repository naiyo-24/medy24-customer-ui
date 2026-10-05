import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state_widget.dart';

class DistributorPoHistoryScreen extends StatelessWidget {
  const DistributorPoHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Procurement Orders', style: AppTextStyles.cardTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const EmptyStateWidget(
        title: 'No Procurement Orders',
        subtitle: 'You have not placed any orders to manufacturers yet.',
        icon: Iconsax.box,
      ),
    );
  }
}
