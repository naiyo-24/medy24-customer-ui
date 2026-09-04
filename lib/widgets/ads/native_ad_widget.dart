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

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget> with AutomaticKeepAliveClientMixin {
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
    super.build(context);
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
