import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../providers/ad_provider.dart';
import '../../theme/app_theme.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  final AdSize? size;
  
  const BannerAdWidget({
    super.key,
    this.size, // If null, uses Anchored Adaptive Banner
  });

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> with AutomaticKeepAliveClientMixin {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  AdSize? _actualAdSize;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAd();
    });
  }

  Future<void> _loadAd() async {
    final String adUnitId = Platform.isAndroid
        ? (dotenv.env['ADMOB_BANNER_ANDROID'] ?? 'ca-app-pub-3940256099942544/6300978111')
        : (dotenv.env['ADMOB_BANNER_IOS'] ?? 'ca-app-pub-3940256099942544/2934735716');

    AdSize? targetSize = widget.size;
    if (targetSize == null) {
      // Get the adaptive size
      final screenWidth = MediaQuery.of(context).size.width.truncate();
      targetSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(screenWidth);
      targetSize ??= AdSize.banner; // fallback
    }

    if (!mounted) return;

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: targetSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
              _actualAdSize = (ad as BannerAd).size;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoaded && _bannerAd != null && _actualAdSize != null) {
      return SizedBox(
        width: _actualAdSize!.width.toDouble(),
        height: _actualAdSize!.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    
    // Return a skeleton while loading
    final width = widget.size?.width.toDouble() ?? double.infinity;
    final height = widget.size?.height.toDouble() ?? 60.0;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(20)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.ad_units, color: Colors.grey, size: 24),
            const SizedBox(height: 4),
            Text(
              'Advertisement',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
