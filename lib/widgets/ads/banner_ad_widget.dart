import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../providers/ad_provider.dart';
import '../../theme/app_theme.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  final AdSize size;
  
  const BannerAdWidget({
    super.key,
    this.size = AdSize.banner,
  });

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> with AutomaticKeepAliveClientMixin {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Schedule the ad grab after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAd();
    });
  }

  void _loadAd() {
    // Try to get a pre-fetched ad from the provider
    final preloadedAd = ref.read(adProvider.notifier).getBannerAd();
    if (preloadedAd != null) {
      setState(() {
        _bannerAd = preloadedAd;
        _isLoaded = true;
      });
    } else {
      // If none available, we could listen for changes, or just show shimmer
      // For now, the provider immediately begins loading a new one, 
      // but we will just wait until next build or rebuild when state changes.
    }
  }

  @override
  void dispose() {
    // We dispose of the ad when the widget leaves the screen
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Listen to ad state so if an ad wasn't ready initially, we grab it when it is
    ref.listen<AdState>(adProvider, (previous, next) {
      if (!_isLoaded && next.bannerAds.isNotEmpty) {
        _loadAd();
      }
    });

    if (_isLoaded && _bannerAd != null) {
      return Container(
        width: widget.size.width.toDouble(),
        height: widget.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      );
    }
    
    // Return a skeleton while loading (without flutter_animate to avoid Impeller errors)
    return Container(
      width: widget.size.width.toDouble(),
      height: widget.size.height.toDouble(),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(20)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.ad_units, color: Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(
              'Advertisement',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
