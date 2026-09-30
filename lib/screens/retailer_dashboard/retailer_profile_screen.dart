import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RetailerProfileScreen extends StatelessWidget {
  const RetailerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile & Compliance', style: AppTextStyles.cardTitle)),
      body: const Center(child: Text('Verification Status / Document Uploads')),
    );
  }
}
