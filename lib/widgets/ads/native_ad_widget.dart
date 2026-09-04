import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../theme/app_theme.dart';
import '../../providers/ad_provider.dart';

class NativeAdWidget extends ConsumerStatefulWidget {
  final TemplateType templateType;
  
  const NativeAdWidget({
    super.key,
    this.templateType = TemplateType.small,
  });

  @override
  ConsumerState<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAd();
    });
  }

  void _loadAd() {
    final preloadedAd = ref.read(adProvider.notifier).getNativeAd();
    if (preloadedAd != null) {
      setState(() {
        _nativeAd = preloadedAd;
        _isLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AdState>(adProvider, (previous, next) {
      if (!_isLoaded && next.nativeAds.isNotEmpty) {
        _loadAd();
      }
    });

    if (_isLoaded && _nativeAd != null) {
      final double adHeight = widget.templateType == TemplateType.small ? 120 : 320;
      
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
    
    final double adHeight = widget.templateType == TemplateType.small ? 120 : 320;
    return Container(
      height: adHeight,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(20),
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
    );
  }
}
