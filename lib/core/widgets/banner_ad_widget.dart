import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';

/// Reusable Banner Ad Widget
/// This widget automatically loads and displays a banner ad
class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsets? margin;
  final Color? backgroundColor;

  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.margin,
    this.backgroundColor,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // Ensure AdMob is initialized before loading ads
    AdMobService.instance.ensureInitialized().then((isInitialized) {
      if (!isInitialized) {
        print('❌ AdMob initialization failed');
        if (mounted) {
          setState(() => _isAdFailed = true);
        }
        return;
      }

      if (!mounted) return;

      print(
        '🔄 Loading banner ad with unit ID: ${AdMobService.instance.bannerAdUnitId}',
      );

      _bannerAd = AdMobService.instance.createBannerAd(
        adSize: widget.adSize,
        onAdLoaded: (ad) {
          print('✅ Banner ad loaded successfully');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
              _isAdFailed = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Banner ad failed to load: $error');
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
              _isAdFailed = true;
            });
          }
          ad.dispose();

          // For production ads, don't retry automatically
          // User can manually retry by tapping the retry button
        },
      );

      _bannerAd?.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything if ad failed to load (clean UI)
    if (_isAdFailed) {
      return const SizedBox.shrink();
    }

    // Show loading indicator while ad is loading
    if (!_isAdLoaded) {
      return Container(
        margin: widget.margin,
        height: widget.adSize.height.toDouble(),
        color: widget.backgroundColor ?? Colors.transparent,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Show the loaded ad
    return Container(
      margin: widget.margin,
      height: widget.adSize.height.toDouble(),
      color: widget.backgroundColor ?? Colors.transparent,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
