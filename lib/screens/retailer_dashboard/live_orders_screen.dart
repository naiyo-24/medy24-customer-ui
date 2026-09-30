import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LiveOrdersScreen extends StatelessWidget {
  const LiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Orders', style: AppTextStyles.cardTitle)),
      body: const Center(child: Text('Live Radar / Active Packing List')),
    );
  }
}
