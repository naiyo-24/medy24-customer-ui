import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EarningsDashboardScreen extends StatelessWidget {
  const EarningsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Earnings & Dashboard', style: AppTextStyles.cardTitle)),
      body: const Center(child: Text('Top KPIs / Earnings Trend')),
    );
  }
}
