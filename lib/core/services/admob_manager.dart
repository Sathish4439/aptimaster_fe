import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:aptimaster/core/services/admob_service.dart';

/// AdMob Manager for handling ad display logic throughout the app
class AdMobManager {
  static final AdMobManager _instance = AdMobManager._internal();
  factory AdMobManager() => _instance;
  AdMobManager._internal();

  InterstitialAd? _interstitialAd;
  bool _isAdLoading = false;
  bool _isAdReady = false;

  /// Load an interstitial ad in the background
  Future<void> loadInterstitialAd() async {
    if (_isAdLoading || _isAdReady) return;

    _isAdLoading = true;

    try {
      _interstitialAd = await AdMobService.instance.loadInterstitialAd();

      if (_interstitialAd != null) {
        _isAdReady = true;
        print('✅ Interstitial ad loaded and ready to show');
      } else {
        print('⚠️ Failed to load interstitial ad');
      }
    } catch (e) {
      print('❌ Error loading interstitial ad: $e');
    } finally {
      _isAdLoading = false;
    }
  }

  /// Show interstitial ad if ready, otherwise execute callback immediately
  void showInterstitialAd({VoidCallback? onAdDismissed}) {
    if (!_isAdReady || _interstitialAd == null) {
      print('⚠️ Interstitial ad not ready, executing callback immediately');
      onAdDismissed?.call();
      return;
    }

    print('🔄 Showing interstitial ad...');
    AdMobService.instance.showInterstitialAd(
      _interstitialAd,
      onAdDismissed: () {
        _isAdReady = false;
        _interstitialAd = null;
        onAdDismissed?.call();
        // Preload next ad after showing current one
        loadInterstitialAd();
      },
    );
  }

  /// Check if ad is ready to be shown
  bool get isAdReady => _isAdReady;

  /// Dispose of current ad
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdReady = false;
    _isAdLoading = false;
  }
}
