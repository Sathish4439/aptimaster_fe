import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:aptimaster/core/services/ad_service.dart';

/// Reusable banner ad widget that can be used across multiple pages
/// Each page gets its own banner ad instance to avoid conflicts
class BannerAdContainer extends StatefulWidget {
  final String pageId; // Unique identifier for each page
  
  const BannerAdContainer({
    super.key,
    required this.pageId,
  });

  @override
  State<BannerAdContainer> createState() => _BannerAdContainerState();
}

class _BannerAdContainerState extends State<BannerAdContainer> {
  @override
  void initState() {
    super.initState();
    // Load banner ad for this specific page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final adService = Get.find<AdService>();
          adService.loadBannerAdForPage(widget.pageId);
        } catch (e) {
          print('Error loading ad: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    // Dispose banner ad when page is disposed
    try {
      if (Get.isRegistered<AdService>()) {
        final adService = Get.find<AdService>();
        adService.disposeBannerAdForPage(widget.pageId);
      }
    } catch (e) {
      print('Error disposing ad: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AdService>()) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      try {
        final adService = Get.find<AdService>();
        final bannerAd = adService.getBannerAdForPage(widget.pageId);
        final isLoaded = adService.isBannerLoadedForPage(widget.pageId);
        final isLoading = adService.isBannerLoadingForPage(widget.pageId);

        if (bannerAd != null && isLoaded) {
          // Ad loaded successfully
          return Container(
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              child: Container(
                alignment: Alignment.center,
                width: bannerAd.size.width.toDouble(),
                height: bannerAd.size.height.toDouble(),
                child: AdWidget(ad: bannerAd),
              ),
            ),
          );
        } else if (isLoading) {
          // Ad is loading - show placeholder
          return Container(
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Loading ad...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        // No ad to show
        return const SizedBox.shrink();
      } catch (e) {
        print('Error building ad widget: $e');
        return const SizedBox.shrink();
      }
    });
  }
}
