import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      targetSize = await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(Orientation.portrait, screenWidth);
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
    
    return const SizedBox.shrink();
  }
}
