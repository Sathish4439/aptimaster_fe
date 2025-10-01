import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:aptimaster/core/config/ad_config.dart';

/// Service to manage Google AdMob ads
/// Handles loading, showing, and disposing of ads
class AdService extends GetxController {
  static AdService get to => Get.find();

  // Ad instances
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Cached AdWidget to prevent "already in widget tree" error
  Widget? _cachedBannerWidget;

  // Ad loaded states
  final RxBool isBannerLoaded = false.obs;
  final RxBool isInterstitialLoaded = false.obs;
  final RxBool isRewardedLoaded = false.obs;

  // Ad loading states
  final RxBool isBannerLoading = false.obs;
  final RxBool isInterstitialLoading = false.obs;
  final RxBool isRewardedLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (AdConfig.adsEnabled) {
      initializeAds();
    }
  }

  /// Initialize AdMob SDK and load initial ads
  Future<void> initializeAds() async {
    try {
      print('🎯 Initializing Google AdMob...');
      print('📋 Ad Mode: ${AdConfig.useTesting ? "TEST ADS (Development)" : "REAL ADS (Production)"}');
      print('⚙️  Banner Ads: ${AdConfig.showBannerAds ? "Enabled" : "Disabled"}');
      print('⚙️  Interstitial Ads: ${AdConfig.showInterstitialAds ? "Enabled" : "Disabled"}');
      print('⚙️  Rewarded Ads: ${AdConfig.showRewardedAds ? "Enabled" : "Disabled"}');
      await MobileAds.instance.initialize();
      print('✅ AdMob initialized successfully');

      // Load initial ads
      if (AdConfig.showBannerAds) loadBannerAd();
      if (AdConfig.showInterstitialAds) loadInterstitialAd();
      if (AdConfig.showRewardedAds) loadRewardedAd();
    } catch (e) {
      print('❌ Error initializing AdMob: $e');
    }
  }

  // ============================================
  // BANNER AD METHODS
  // ============================================

  /// Load a banner ad
  void loadBannerAd() {
    if (!AdConfig.showBannerAds || isBannerLoading.value) return;

    isBannerLoading.value = true;
    print('📱 Loading banner ad...');

    _bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('✅ Banner ad loaded successfully');
          isBannerLoaded.value = true;
          isBannerLoading.value = false;
          // Create and cache the AdWidget
          final bannerAd = ad as BannerAd;
          _cachedBannerWidget = Container(
            alignment: Alignment.center,
            width: bannerAd.size.width.toDouble(),
            height: bannerAd.size.height.toDouble(),
            child: AdWidget(ad: bannerAd),
          );
        },
        onAdFailedToLoad: (ad, error) {
          if (AdConfig.showAdErrorLogs) {
            print('❌ Banner ad failed to load: ${AdConfig.getErrorMessage(error.code)}');
            print('   Error details: $error');
          }
          ad.dispose();
          isBannerLoaded.value = false;
          isBannerLoading.value = false;
          _cachedBannerWidget = null; // Clear cached widget

          // Retry after configured delay
          Future.delayed(Duration(seconds: AdConfig.adRetryDelaySeconds), () {
            if (!isBannerLoaded.value) {
              loadBannerAd();
            }
          });
        },
        onAdOpened: (ad) {
          print('📱 Banner ad opened');
        },
        onAdClosed: (ad) {
          print('📱 Banner ad closed');
        },
      ),
    )..load();
  }

  /// Get banner ad widget to display in UI
  /// Returns cached widget to prevent "already in widget tree" error
  Widget? getBannerAdWidget() {
    if (_bannerAd != null && isBannerLoaded.value && _cachedBannerWidget != null) {
      return _cachedBannerWidget;
    }
    return null;
  }

  /// Dispose banner ad
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _cachedBannerWidget = null; // Clear cached widget
    isBannerLoaded.value = false;
    isBannerLoading.value = false;
  }

  // ============================================
  // INTERSTITIAL AD METHODS
  // ============================================

  /// Load an interstitial ad
  void loadInterstitialAd() {
    if (!AdConfig.showInterstitialAds || isInterstitialLoading.value) return;

    isInterstitialLoading.value = true;
    print('🎬 Loading interstitial ad...');

    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ Interstitial ad loaded successfully');
          _interstitialAd = ad;
          isInterstitialLoaded.value = true;
          isInterstitialLoading.value = false;

          // Set full screen content callback
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              print('🎬 Interstitial ad showed full screen');
            },
            onAdDismissedFullScreenContent: (ad) {
              print('🎬 Interstitial ad dismissed');
              ad.dispose();
              isInterstitialLoaded.value = false;
              // Load next interstitial ad
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('❌ Interstitial ad failed to show: $error');
              ad.dispose();
              isInterstitialLoaded.value = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          if (AdConfig.showAdErrorLogs) {
            print('❌ Interstitial ad failed to load: ${AdConfig.getErrorMessage(error.code)}');
            print('   Error details: $error');
          }
          isInterstitialLoaded.value = false;
          isInterstitialLoading.value = false;

          // Retry after configured delay
          Future.delayed(Duration(seconds: AdConfig.adRetryDelaySeconds), () {
            if (!isInterstitialLoaded.value) {
              loadInterstitialAd();
            }
          });
        },
      ),
    );
  }

  /// Show interstitial ad
  void showInterstitialAd({VoidCallback? onAdClosed}) {
    if (!AdConfig.showInterstitialAds) {
      onAdClosed?.call();
      return;
    }

    if (_interstitialAd != null && isInterstitialLoaded.value) {
      print('🎬 Showing interstitial ad...');

      // Update callback to include custom onAdClosed
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          print('🎬 Interstitial ad showed full screen');
        },
        onAdDismissedFullScreenContent: (ad) {
          print('🎬 Interstitial ad dismissed');
          ad.dispose();
          isInterstitialLoaded.value = false;
          onAdClosed?.call();
          // Load next interstitial ad
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('❌ Interstitial ad failed to show: $error');
          ad.dispose();
          isInterstitialLoaded.value = false;
          onAdClosed?.call();
          loadInterstitialAd();
        },
      );

      _interstitialAd!.show();
    } else {
      print('⚠️ Interstitial ad not ready, executing callback immediately');
      onAdClosed?.call();
      // Try to load ad for next time
      if (!isInterstitialLoading.value) {
        loadInterstitialAd();
      }
    }
  }

  // ============================================
  // REWARDED AD METHODS
  // ============================================

  /// Load a rewarded ad
  void loadRewardedAd() {
    if (!AdConfig.showRewardedAds || isRewardedLoading.value) return;

    isRewardedLoading.value = true;
    print('🎁 Loading rewarded ad...');

    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          print('✅ Rewarded ad loaded successfully');
          _rewardedAd = ad;
          isRewardedLoaded.value = true;
          isRewardedLoading.value = false;
        },
        onAdFailedToLoad: (error) {
          if (AdConfig.showAdErrorLogs) {
            print('❌ Rewarded ad failed to load: ${AdConfig.getErrorMessage(error.code)}');
            print('   Error details: $error');
          }
          isRewardedLoaded.value = false;
          isRewardedLoading.value = false;

          // Retry after configured delay
          Future.delayed(Duration(seconds: AdConfig.adRetryDelaySeconds), () {
            if (!isRewardedLoaded.value) {
              loadRewardedAd();
            }
          });
        },
      ),
    );
  }

  /// Show rewarded ad
  void showRewardedAd({
    required Function(int amount) onRewarded,
    VoidCallback? onAdClosed,
  }) {
    if (!AdConfig.showRewardedAds) {
      print('⚠️ Rewarded ads are disabled');
      return;
    }

    if (_rewardedAd != null && isRewardedLoaded.value) {
      print('🎁 Showing rewarded ad...');

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          print('🎁 Rewarded ad showed full screen');
        },
        onAdDismissedFullScreenContent: (ad) {
          print('🎁 Rewarded ad dismissed');
          ad.dispose();
          isRewardedLoaded.value = false;
          onAdClosed?.call();
          // Load next rewarded ad
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('❌ Rewarded ad failed to show: $error');
          ad.dispose();
          isRewardedLoaded.value = false;
          onAdClosed?.call();
          loadRewardedAd();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('🎁 User earned reward: ${reward.amount} ${reward.type}');
          onRewarded(reward.amount.toInt());
        },
      );
    } else {
      print('⚠️ Rewarded ad not ready');
      // Try to load ad for next time
      if (!isRewardedLoading.value) {
        loadRewardedAd();
      }
    }
  }

  // ============================================
  // CLEANUP
  // ============================================

  @override
  void onClose() {
    print('🧹 Disposing all ads...');
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.onClose();
  }
}
