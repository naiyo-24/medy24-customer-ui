import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../theme/app_theme.dart';

class AdState {
  final List<NativeAd> nativeAds;
  final List<BannerAd> bannerAds;

  AdState({
    this.nativeAds = const [],
    this.bannerAds = const [],
  });

  AdState copyWith({
    List<NativeAd>? nativeAds,
    List<BannerAd>? bannerAds,
  }) {
    return AdState(
      nativeAds: nativeAds ?? this.nativeAds,
      bannerAds: bannerAds ?? this.bannerAds,
    );
  }
}

class AdNotifier extends StateNotifier<AdState> {
  AdNotifier() : super(AdState()) {
    _initAds();
  }

  // Define how many ads to keep in memory at a time
  static const int _maxNativeAds = 2;
  static const int _maxBannerAds = 2;

  static String _getAdUnitId(String key, String fallback) {
    final val = dotenv.env[key];
    if (val != null && val.isNotEmpty) {
      return val;
    }
    return fallback;
  }

  final String _nativeAdUnitId = Platform.isAndroid
      ? _getAdUnitId('ADMOB_NATIVE_ANDROID', 'ca-app-pub-3940256099942544/2247696110')
      : _getAdUnitId('ADMOB_NATIVE_IOS', 'ca-app-pub-3940256099942544/3986624511');

  final String _bannerAdUnitId = Platform.isAndroid
      ? _getAdUnitId('ADMOB_BANNER_ANDROID', 'ca-app-pub-3940256099942544/6300978111')
      : _getAdUnitId('ADMOB_BANNER_IOS', 'ca-app-pub-3940256099942544/2934735716');

  Future<void> _initAds() async {
    // Set test device ID to avoid Error 3 (NO_FILL) during development
    RequestConfiguration configuration = RequestConfiguration(
      testDeviceIds: ['4D6E30A9DD34758AE58431905A044486'],
    );
    await MobileAds.instance.updateRequestConfiguration(configuration);

    // Pre-load the initial batch of ads
    _preloadNativeAds();
    _preloadBannerAds();
  }

  void _preloadNativeAds() {
    final needed = _maxNativeAds - state.nativeAds.length;
    for (int i = 0; i < needed; i++) {
      final ad = NativeAd(
        adUnitId: _nativeAdUnitId,
        factoryId: '', // Unused for Template style
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            debugPrint('Preloaded NativeAd.');
            state = state.copyWith(
              nativeAds: [...state.nativeAds, ad as NativeAd],
            );
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('NativeAd failed to load: \$error');
            ad.dispose();
          },
        ),
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.small,
          mainBackgroundColor: AppColors.surface,
          cornerRadius: 16.0,
          callToActionTextStyle: NativeTemplateTextStyle(
            textColor: Colors.white,
            backgroundColor: AppColors.primary,
            style: NativeTemplateFontStyle.bold,
            size: 16.0,
          ),
          primaryTextStyle: NativeTemplateTextStyle(
            textColor: AppColors.textPrimary,
            backgroundColor: Colors.transparent,
            style: NativeTemplateFontStyle.bold,
            size: 16.0,
          ),
          secondaryTextStyle: NativeTemplateTextStyle(
            textColor: AppColors.textSecondary,
            backgroundColor: Colors.transparent,
            style: NativeTemplateFontStyle.normal,
            size: 14.0,
          ),
          tertiaryTextStyle: NativeTemplateTextStyle(
            textColor: AppColors.textSecondary,
            backgroundColor: Colors.transparent,
            style: NativeTemplateFontStyle.normal,
            size: 14.0,
          ),
        ),
      )..load();
    }
  }

  void _preloadBannerAds() {
    final needed = _maxBannerAds - state.bannerAds.length;
    for (int i = 0; i < needed; i++) {
      final ad = BannerAd(
        adUnitId: _bannerAdUnitId,
        request: const AdRequest(),
        size: AdSize.mediumRectangle,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('Preloaded BannerAd.');
            state = state.copyWith(
              bannerAds: [...state.bannerAds, ad as BannerAd],
            );
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('BannerAd failed to load: \$error');
            ad.dispose();
          },
        ),
      )..load();
    }
  }

  NativeAd? getNativeAd() {
    if (state.nativeAds.isEmpty) {
      _preloadNativeAds();
      return null;
    }
    final ad = state.nativeAds.first;
    state = state.copyWith(
      nativeAds: state.nativeAds.sublist(1),
    );
    // Replenish the pool
    _preloadNativeAds();
    return ad;
  }

  BannerAd? getBannerAd() {
    if (state.bannerAds.isEmpty) {
      _preloadBannerAds();
      return null;
    }
    final ad = state.bannerAds.first;
    state = state.copyWith(
      bannerAds: state.bannerAds.sublist(1),
    );
    // Replenish the pool
    _preloadBannerAds();
    return ad;
  }

  @override
  void dispose() {
    for (var ad in state.nativeAds) {
      ad.dispose();
    }
    for (var ad in state.bannerAds) {
      ad.dispose();
    }
    super.dispose();
  }
}

final adProvider = StateNotifierProvider<AdNotifier, AdState>((ref) {
  return AdNotifier();
});
