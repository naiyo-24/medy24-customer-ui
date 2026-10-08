import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../theme/app_theme.dart';

class NativeAdWidget extends StatefulWidget {
  final TemplateType templateType;
  
  const NativeAdWidget({
    super.key,
    this.templateType = TemplateType.small,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> with AutomaticKeepAliveClientMixin {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAd();
    });
  }

  void _loadAd() {
    String adUnitId;
    if (widget.templateType == TemplateType.medium) {
      // Use Video Native Ad Unit for medium template
      adUnitId = Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1044960115'
          : 'ca-app-pub-3940256099942544/2521693316';
    } else {
      // Use Image Native Ad Unit for small template
      adUnitId = Platform.isAndroid
          ? (dotenv.env['ADMOB_NATIVE_ANDROID'] ?? 'ca-app-pub-3940256099942544/2247696110')
          : (dotenv.env['ADMOB_NATIVE_IOS'] ?? 'ca-app-pub-3940256099942544/3986624511');
    }

    _nativeAd = NativeAd(
      adUnitId: adUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('NativeAd failed to load: $error');
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.templateType,
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

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoaded && _nativeAd != null) {
      final double adHeight = widget.templateType == TemplateType.small ? 120 : 350;
      
      return Container(
        height: adHeight,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: AdWidget(ad: _nativeAd!),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}
