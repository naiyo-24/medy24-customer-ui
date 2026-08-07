import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/advertisement.dart';
import '../services/api_url.dart';
import '../theme/app_theme.dart';

class PromoBannerCarousel extends StatefulWidget {
  final List<AdvertisementModel> banners;

  const PromoBannerCarousel({super.key, required this.banners});

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    if (widget.banners.isEmpty) return;
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < widget.banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _PromoBannerCard(banner: widget.banners[index]),
              );
            },
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 6),
              width: _currentPage == index ? 24 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.primary
                    : AppColors.textTertiary.withAlpha(80),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PromoBannerCard extends StatelessWidget {
  final AdvertisementModel banner;

  const _PromoBannerCard({required this.banner});

  Future<void> _launchUrl() async {
    if (banner.targetUrl == null || banner.targetUrl!.isEmpty) return;
    final url = Uri.parse(banner.targetUrl!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchUrl,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: banner.imageUrl.startsWith('file://')
              ? Image.file(
                  File(banner.imageUrl.replaceFirst('file://', '')),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.background,
                    child: const Center(
                      child: Icon(Icons.broken_image_rounded, color: AppColors.textTertiary),
                    ),
                  ),
                )
              : banner.imageUrl.startsWith('assets/')
                  ? Image.asset(
                      banner.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.background,
                        child: const Center(
                          child: Icon(Icons.broken_image_rounded, color: AppColors.textTertiary),
                        ),
                      ),
                    )
                  : Image.network(
                      ApiUrl.imageUrl(banner.imageUrl),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.background,
                        child: const Center(
                          child: Icon(Icons.broken_image_rounded, color: AppColors.textTertiary),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}
