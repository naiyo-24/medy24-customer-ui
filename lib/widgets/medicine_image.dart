import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class MedicineImage extends StatelessWidget {
  final String? photoUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final double iconSize;

  const MedicineImage({
    super.key,
    required this.photoUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.iconSize = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return Image.asset(
        'assets/logo/demo_med_image.png',
        fit: fit,
        width: width,
        height: height,
      );
    }

    return Image.network(
      photoUrl!,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/logo/demo_med_image.png',
          fit: fit,
          width: width,
          height: height,
        );
      },
    );
  }
}
