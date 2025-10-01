import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:aptimaster/core/config/ad_config.dart';

/// Service to manage Google AdMob ads
/// Handles loading, showing, and disposing of ads
class AdService extends GetxController {
  static AdService get to => Get.find();

  // Ad instances - Multiple banner ads for different pages
  final Map<String, BannerAd> _bannerAds = {};
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Ad loaded states - Track each banner ad separately
  final RxMap<String, bool> bannerAdsLoaded = <String, bool>{}.obs;
  final RxBool isInterstitialLoaded = false.obs;
  final RxBool isRewardedLoaded = false.obs;

  // Ad loading states - Track each banner ad separately
  final RxMap<String, bool> bannerAdsLoading = <String, bool>{}.obs;
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
      print(
        '📋 Ad Mode: ${AdConfig.useTesting ? "TEST ADS (Development)" : "REAL ADS (Production)"}',
      );
      print(
        '⚙️  Banner Ads: ${AdConfig.showBannerAds ? "Enabled" : "Disabled"}',
      );
      print(
        '⚙️  Interstitial Ads: ${AdConfig.showInterstitialAds ? "Enabled" : "Disabled"}',
      );
      print(
        '⚙️  Rewarded Ads: ${AdConfig.showRewardedAds ? "Enabled" : "Disabled"}',
      );

      // Register test device IDs to reduce "No fill" during development
      if (AdConfig.useTesting) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(
            testDeviceIds: const ['239DB99DA7DFDC458DA87EAAD8A0CCA0'],
          ),
        );
        print('🧪 Test device IDs registered');
      }

      await MobileAds.instance.initialize();
      print('✅ AdMob initialized successfully');

      // Don't load ads automatically - each page will load its own
      if (AdConfig.showInterstitialAds) loadInterstitialAd();
      if (AdConfig.showRewardedAds) loadRewardedAd();
    } catch (e) {
      print('❌ Error initializing AdMob: $e');
    }
  }

  // ============================================
  // BANNER AD METHODS - Multiple ads per page
  // ============================================

  /// Load a banner ad for a specific page
  void loadBannerAdForPage(String pageId) {
    if (!AdConfig.showBannerAds || (bannerAdsLoading[pageId] ?? false)) return;

    bannerAdsLoading[pageId] = true;
    print('📱 Loading banner ad for page: $pageId...');

    final bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('✅ Banner ad loaded for page: $pageId');
          _bannerAds[pageId] = ad as BannerAd;
          bannerAdsLoaded[pageId] = true;
          bannerAdsLoading[pageId] = false;
        },
        onAdFailedToLoad: (ad, error) {
          if (AdConfig.showAdErrorLogs) {
            print(
              '❌ Banner ad failed for $pageId: ${AdConfig.getErrorMessage(error.code)}',
            );
          }
          ad.dispose();
          bannerAdsLoaded[pageId] = false;
          bannerAdsLoading[pageId] = false;

          // Retry after delay
          Future.delayed(Duration(seconds: AdConfig.adRetryDelaySeconds), () {
            if (!(bannerAdsLoaded[pageId] ?? false)) {
              loadBannerAdForPage(pageId);
            }
          });
        },
        onAdOpened: (ad) => print('📱 Banner ad opened: $pageId'),
        onAdClosed: (ad) => print('📱 Banner ad closed: $pageId'),
      ),
    )..load();
  }

  /// Get banner ad for a specific page
  BannerAd? getBannerAdForPage(String pageId) => _bannerAds[pageId];

  /// Check if banner ad is loaded for a page
  bool isBannerLoadedForPage(String pageId) => bannerAdsLoaded[pageId] ?? false;

  /// Check if banner ad is loading for a page
  bool isBannerLoadingForPage(String pageId) =>
      bannerAdsLoading[pageId] ?? false;

  /// Dispose banner ad for a specific page
  void disposeBannerAdForPage(String pageId) {
    _bannerAds[pageId]?.dispose();
    _bannerAds.remove(pageId);
    bannerAdsLoaded.remove(pageId);
    bannerAdsLoading.remove(pageId);
  }

  /// Dispose all banner ads
  void disposeAllBannerAds() {
    for (var ad in _bannerAds.values) {
      ad.dispose();
    }
    _bannerAds.clear();
    bannerAdsLoaded.clear();
    bannerAdsLoading.clear();
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
            print(
              '❌ Interstitial ad failed to load: ${AdConfig.getErrorMessage(error.code)}',
            );
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
            print(
              '❌ Rewarded ad failed to load: ${AdConfig.getErrorMessage(error.code)}',
            );
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
    disposeAllBannerAds();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.onClose();
  }
}
