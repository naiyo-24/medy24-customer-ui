import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../models/about_us.dart';
import '../../theme/app_theme.dart';
import '../../services/api_url.dart';

class PartnerCard extends StatelessWidget {
  final AboutUsModel aboutUs;

  const PartnerCard({super.key, required this.aboutUs});

  @override
  Widget build(BuildContext context) {
    if (aboutUs.partners == null || aboutUs.partners!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding * 1.5),
      decoration: AppCardStyles.sleekCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.global,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Strategic Partners',
                style: AppTextStyles.cardTitle.copyWith(letterSpacing: -0.5),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: aboutUs.partners!.length,
              separatorBuilder: (context, index) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                final partner = aboutUs.partners![index];
                return _buildPartnerItem(partner);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerItem(dynamic partner) {
    String? logoUrl;
    String? name;

    if (partner is Map) {
      logoUrl = partner['logo_url'] ?? partner['logo'];
      name = partner['name'];
    } else if (partner is String) {
      name = partner;
    }

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.divider.withAlpha(100)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.network(
                      logoUrl.startsWith('http')
                          ? logoUrl
                          : ApiUrl.imageUrl(logoUrl),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Iconsax.briefcase,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : const Icon(
                    Iconsax.briefcase,
                    size: 24,
                    color: AppColors.primary,
                  ),
          ),
        ),
        if (name != null) ...[
          const SizedBox(height: 8),
          Text(
            name,
            style: AppTextStyles.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary.withAlpha(200),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
