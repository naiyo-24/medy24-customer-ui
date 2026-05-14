import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/lab_test.dart';
import '../../theme/app_theme.dart';
import '../../services/api_url.dart';
import '../../providers/patho_lab_provider.dart';

class LabTestHeaderCard extends ConsumerWidget {
  final LabTestInventoryModel test;

  const LabTestHeaderCard({super.key, required this.test});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final core = test.coreTestDetails;
    if (core == null) return const SizedBox.shrink();

    final labs = ref.watch(pathoLabProvider).labs;
    final lab = labs.where((l) => l.labId == test.labId).firstOrNull;
    final labName = lab?.labName ?? 'Loading lab...';

    return Stack(
      children: [
        // Background Image with Parallax-ready fit
        if (core.testPhotoUrl != null)
          Positioned.fill(
            child: Image.network(
              ApiUrl.imageUrl(core.testPhotoUrl!),
              fit: BoxFit.cover,
            ),
          ),
        // Gradient Overlay for readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(80),
                  Colors.transparent,
                  Colors.black.withAlpha(200),
                ],
              ),
            ),
          ),
        ),
        // Content
        Positioned(
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge/Category
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(200),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  core.testCategory.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Test Name
              Text(
                core.testName,
                style: AppTextStyles.header.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              // Lab Info
              Row(
                children: [
                  const Icon(
                    Iconsax.hospital,
                    color: AppColors.primary,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      labName,
                      style: AppTextStyles.tagline.copyWith(
                        color: Colors.white.withAlpha(220),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
