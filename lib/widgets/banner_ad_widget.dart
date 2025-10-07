import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:aptimaster/core/services/admob_service.dart';

/// Reusable Banner Ad Widget
/// This widget handles banner ad creation, loading, and display
class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsets? margin;
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdFailedToLoad;
  final bool enabled;

  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.margin,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.enabled = true,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdFailed = false;
  int _retryAttempts = 0;
  static const int _maxRetryAttempts = 5;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _loadAd();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAd() async {
    if (!widget.enabled || _isAdLoading || _isAdLoaded) return;

    setState(() {
      _isAdLoading = true;
    });

    try {
      // Ensure AdMob is initialized
      await AdMobService.instance.ensureInitialized();

      _bannerAd = AdMobService.instance.createBannerAd(
        adSize: widget.adSize,
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
            _isAdLoading = false;
            _isAdFailed = false;
          });
          widget.onAdLoaded?.call();
          print('✅ Banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          widget.onAdFailedToLoad?.call();

          // Handle different error types
          if (error.code == 3) {
            _retryAttempts++;
            if (_retryAttempts < _maxRetryAttempts) {
              // No fill error - try again with shorter delay for testing
              int delaySeconds =
                  5; // Reduced to 5 seconds for immediate testing
              print(
                '⚠️ No fill error (attempt $_retryAttempts/$_maxRetryAttempts) - will retry in $delaySeconds seconds',
              );

              // Reset state for retry
              setState(() {
                _isAdFailed = false;
                _isAdLoading = false;
                _isAdLoaded = false;
              });

              Future.delayed(Duration(seconds: delaySeconds), () {
                if (mounted && widget.enabled) {
                  print('🔄 Attempting retry $_retryAttempts...');
                  _retryLoadAd();
                }
              });
            } else {
              setState(() {
                _isAdFailed = true;
                _isAdLoading = false;
                _isAdLoaded = false;
              });
              print(
                '❌ Banner ad failed after $_maxRetryAttempts attempts - giving up (No fill)',
              );
            }
          } else {
            setState(() {
              _isAdFailed = true;
              _isAdLoading = false;
              _isAdLoaded = false;
            });
            print(
              '❌ Banner ad failed to load: ${error.message} (Code: ${error.code})',
            );
          }
          ad.dispose();
        },
      );

      await _bannerAd!.load();
    } catch (e) {
      setState(() {
        _isAdFailed = true;
        _isAdLoading = false;
      });
      print('❌ Error creating banner ad: $e');
    }
  }

  /// Retry loading ad after no-fill error
  Future<void> _retryLoadAd() async {
    print(
      '🔄 Retry method called - Current state: loading=$_isAdLoading, loaded=$_isAdLoaded, failed=$_isAdFailed',
    );

    if (_isAdLoading || _isAdLoaded) {
      print('⚠️ Skipping retry - ad already loading or loaded');
      return;
    }

    print('🔄 Starting retry banner ad load...');
    // Dispose any existing failed ad
    _bannerAd?.dispose();
    _bannerAd = null;

    // Reset retry counter and try again
    await _loadAd();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show ads on debug mode unless explicitly enabled
    if (!widget.enabled || kDebugMode && Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    if (_isAdFailed) {
      return const SizedBox.shrink();
    }

    if (_isAdLoading) {
      return Container(
        margin: widget.margin,
        height: widget.adSize.height.toDouble(),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        margin: widget.margin,
        alignment: Alignment.center,
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Predefined banner ad sizes for common use cases
class BannerAdSizes {
  static const AdSize banner = AdSize(width: 320, height: 50);
  static const AdSize largeBanner = AdSize(width: 320, height: 100);
  static const AdSize mediumRectangle = AdSize(width: 300, height: 250);
  static const AdSize fullBanner = AdSize(width: 468, height: 60);
  static const AdSize leaderboard = AdSize(width: 728, height: 90);
  static const AdSize adaptiveBanner = AdSize.banner;
  static const AdSize adaptiveLargeBanner = AdSize.largeBanner;
  static const AdSize adaptiveMediumRectangle = AdSize.mediumRectangle;
  static const AdSize adaptiveFullBanner = AdSize.fullBanner;
}

/// Adaptive Banner Widget that automatically sizes based on screen width
class AdaptiveBannerAdWidget extends StatefulWidget {
  final EdgeInsets? margin;
  final VoidCallback? onAdLoaded;
  final VoidCallback? onAdFailedToLoad;
  final int maxHeight;

  const AdaptiveBannerAdWidget({
    super.key,
    this.margin,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.maxHeight = 50,
  });

  @override
  State<AdaptiveBannerAdWidget> createState() => _AdaptiveBannerAdWidgetState();
}

class _AdaptiveBannerAdWidgetState extends State<AdaptiveBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdFailed = false;

  @override
  void initState() {
    super.initState();
    _loadAdaptiveAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAdaptiveAd() async {
    if (_isAdLoading || _isAdLoaded) return;

    setState(() {
      _isAdLoading = true;
    });

    try {
      // Ensure AdMob is initialized
      await AdMobService.instance.ensureInitialized();

      // Get adaptive banner size
      final adSize = await _getAdaptiveBannerSize();

      _bannerAd = AdMobService.instance.createBannerAd(
        adSize: adSize,
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
            _isAdLoading = false;
            _isAdFailed = false;
          });
          widget.onAdLoaded?.call();
          print('✅ Adaptive banner ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          setState(() {
            _isAdLoaded = false;
            _isAdLoading = false;
            _isAdFailed = true;
          });
          widget.onAdFailedToLoad?.call();
          print('❌ Adaptive banner ad failed to load: ${error.message}');
          ad.dispose();
        },
      );

      await _bannerAd!.load();
    } catch (e) {
      setState(() {
        _isAdFailed = true;
        _isAdLoading = false;
      });
      print('❌ Error creating adaptive banner ad: $e');
    }
  }

  Future<AdSize> _getAdaptiveBannerSize() async {
    final width = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    final adaptiveSize = await AdSize.getAnchoredAdaptiveBannerAdSize(
      orientation,
      width.toInt(),
    );

    // Return the adaptive size or fallback to standard banner
    return adaptiveSize ?? AdSize.banner;
  }

  @override
  Widget build(BuildContext context) {
    // Don't show ads on debug mode
    if (kDebugMode && Platform.isAndroid) {
      return const SizedBox.shrink();
    }

    if (_isAdFailed) {
      return const SizedBox.shrink();
    }

    if (_isAdLoading) {
      return Container(
        margin: widget.margin,
        height: widget.maxHeight.toDouble(),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        margin: widget.margin,
        alignment: Alignment.center,
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Debug-only banner widget for development testing
class DebugBannerAdWidget extends StatelessWidget {
  final AdSize adSize;
  final EdgeInsets? margin;

  const DebugBannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: margin,
      height: adSize.height.toDouble(),
      width: adSize.width.toDouble(),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.3),
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'BANNER AD\n${adSize.width}x${adSize.height}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
