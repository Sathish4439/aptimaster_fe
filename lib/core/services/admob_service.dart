import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob Service for managing ads throughout the app
/// This service provides centralized ad management with test and production ad unit IDs
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  static AdMobService get instance => _instance;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Test Ad Unit IDs (use these for development)
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // Production Ad Unit IDs (your actual AdMob IDs)
  static const String _prodBannerAdUnitIdAndroid =
      'ca-app-pub-3551669458380838/9557136529';
  static const String _prodBannerAdUnitIdIOS =
      'ca-app-pub-3551669458380838/9557136529'; // Same for iOS since you only provided Android ones
  static const String _prodInterstitialAdUnitIdAndroid =
      'ca-app-pub-3551669458380838/5889354254';
  static const String _prodInterstitialAdUnitIdIOS =
      'ca-app-pub-3551669458380838/5889354254'; // Same for iOS
  static const String _prodRewardedAdUnitIdAndroid =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodRewardedAdUnitIdIOS =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';

  // Set this to true for development/testing, false for production
  static const bool _useTestAds =
      true; // TEMPORARILY using test ads to resolve no-fill issue

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Mobile Ads SDK
      final initializationStatus = await MobileAds.instance.initialize();

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ AdMob initialized successfully');
        print('🔧 Using test ads: $_useTestAds');
        print('📱 Banner Ad Unit ID: $bannerAdUnitId');
        print('📱 Interstitial Ad Unit ID: $interstitialAdUnitId');

        // Log adapter status for debugging
        final adapterStatusMap = initializationStatus.adapterStatuses;
        print('📊 Adapter Status: $adapterStatusMap');
      }
    } catch (e) {
      print('❌ Error initializing AdMob: $e');
      rethrow;
    }
  }

  /// Ensure AdMob is initialized and return initialization status
  Future<bool> ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _isInitialized;
  }

  /// Get Banner Ad Unit ID based on platform
  String get bannerAdUnitId {
    if (_useTestAds) {
      return _testBannerAdUnitId;
    }

    if (Platform.isAndroid) {
      return _prodBannerAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _prodBannerAdUnitIdIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get Interstitial Ad Unit ID based on platform
  String get interstitialAdUnitId {
    if (_useTestAds) {
      return _testInterstitialAdUnitId;
    }

    if (Platform.isAndroid) {
      return _prodInterstitialAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _prodInterstitialAdUnitIdIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get Rewarded Ad Unit ID based on platform
  String get rewardedAdUnitId {
    if (_useTestAds) {
      return _testRewardedAdUnitId;
    }

    if (Platform.isAndroid) {
      return _prodRewardedAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _prodRewardedAdUnitIdIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Create a Banner Ad with optimized settings and better error handling
  BannerAd createBannerAd({
    required AdSize adSize,
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
    List<String>? keywords,
    List<String>? nonPersonalizedAdsKeywords,
    String? contentUrl,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: _createAdRequest(
        keywords: keywords,
        nonPersonalizedAdsKeywords: nonPersonalizedAdsKeywords,
        contentUrl: contentUrl,
      ),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode)
            print('✅ Banner ad loaded successfully: ${ad.adUnitId}');
          onAdLoaded(ad);
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('❌ Banner ad failed to load: ${error.message}');
            print('🔍 Error code: ${error.code}');
            print('🔍 Error domain: ${error.domain}');

            // Specific handling for different error types
            switch (error.code) {
              case 0: // No error
                print('ℹ️ No error');
                break;
              case 1: // Invalid request
                print('🔧 Invalid ad request');
                break;
              case 2: // Network error
                print('🌐 Network error');
                break;
              case 3: // No fill
                print('⚠️ No fill - No ads available for this device/region');
                break;
              case 8: // Internal error
                print('⚙️ Internal error');
                break;
              default:
                print('❓ Unknown error code: ${error.code}');
            }
          }
          onAdFailedToLoad(ad, error);
        },
        onAdOpened: (ad) {
          if (kDebugMode) print('📂 Banner ad opened: ${ad.adUnitId}');
        },
        onAdClosed: (ad) {
          if (kDebugMode) print('📤 Banner ad closed: ${ad.adUnitId}');
        },
        onAdImpression: (ad) {
          if (kDebugMode) print('📊 Banner ad impression recorded');
        },
      ),
    );
  }

  /// Create optimized Ad Request with improved targeting and better fill-rate strategies
  AdRequest _createAdRequest({
    List<String>? keywords,
    List<String>? nonPersonalizedAdsKeywords,
    String? contentUrl,
  }) {
    // Configure request for better fill rates
    final requestConfiguration = RequestConfiguration(
      maxAdContentRating: MaxAdContentRating.pg,
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.unspecified,
      // Add test device IDs for debugging
      testDeviceIds: kDebugMode
          ? [
              'TEST-DEVICE-ID', // Replace with your test device ID
              'B2077A6E1AF8E3C87EDE2F8C7ECF43B4', // Example test device ID
              '33BE2250B435941C', // Common test device ID
            ]
          : null,
    );

    // Always update request configuration for consistency
    MobileAds.instance.updateRequestConfiguration(requestConfiguration);

    // Create ad request with optimized targeting for better fill rates
    return AdRequest(
      keywords:
          keywords ??
          <String>[
            'education',
            'aptitude',
            'exam',
            'preparation',
            'learning',
            'study',
            'test',
            'quantitative',
            'verbal',
            'reasoning',
            'online',
            'mobile',
            'app',
          ],
      nonPersonalizedAds: false, // Use personalized ads for better targeting
      contentUrl: contentUrl ?? 'https://aptimaster.app',
    );
  }

  /// Get device ID for testing (call this in your app to get your test device id)
  static Future<String> printTestDeviceId() async {
    if (kDebugMode) {
      try {
        final config = await MobileAds.instance.getRequestConfiguration();
        String? deviceId = config.testDeviceIds?.first;
        print('📱 Test Device ID: $deviceId');
        print('📱 Add this ID to your AdMob test devices list');
        print('🔗 Go to: https://admob.google.com → Settings → Test devices');
      } catch (e) {
        print('❌ Error getting device ID: $e');
      }

      // AdMob will also log the device ID automatically
      print(
        '📱 Check AdMob logs for: "Use AdRequest.Builder.addTestDevice("\<DEVICE_ID\>")"',
      );
      print('📱 Or look for: "No fill." messages which contain your device ID');
    }
    return '';
  }

  /// Print current AdMob configuration for debugging
  static void printAdMobConfig() {
    if (kDebugMode) {
      print('🔧 AdMob Configuration:');
      print('   Using Test Ads: $_useTestAds');
      print('   Banner Ad Unit ID: ${instance.bannerAdUnitId}');
      print('   Interstitial Ad Unit ID: ${instance.interstitialAdUnitId}');
      print('   AdMob Initialized: ${instance.isInitialized}');
      print('   Platform: ${Platform.isAndroid ? 'Android' : 'iOS'}');
    }
  }

  /// Load an Interstitial Ad with optimized settings
  Future<InterstitialAd?> loadInterstitialAd({
    List<String>? keywords,
    String? contentUrl,
  }) async {
    InterstitialAd? interstitialAd;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: _createAdRequest(keywords: keywords, contentUrl: contentUrl),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          if (kDebugMode) print('✅ Interstitial ad loaded: ${ad.adUnitId}');
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('❌ Interstitial ad failed to load: ${error.message}');
          }
        },
      ),
    );

    return interstitialAd;
  }

  /// Load a Rewarded Ad with optimized settings
  Future<RewardedAd?> loadRewardedAd({
    List<String>? keywords,
    String? contentUrl,
  }) async {
    RewardedAd? rewardedAd;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: _createAdRequest(keywords: keywords, contentUrl: contentUrl),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          if (kDebugMode) print('✅ Rewarded ad loaded: ${ad.adUnitId}');
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('❌ Rewarded ad failed to load: ${error.message}');
          }
        },
      ),
    );

    return rewardedAd;
  }

  /// Show Interstitial Ad
  void showInterstitialAd(InterstitialAd? ad, {VoidCallback? onAdDismissed}) {
    if (ad == null) {
      if (kDebugMode) print('⚠️ Interstitial ad is not ready yet');
      onAdDismissed?.call();
      return;
    }

    // Store a local reference to the ad
    final adToShow = ad;

    // Set callbacks first before showing the ad
    adToShow.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        if (kDebugMode) print('✅ Interstitial ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        if (kDebugMode) print('ℹ️ Interstitial ad dismissed');
        ad.dispose();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) print('❌ Interstitial ad failed to show: $error');
        ad.dispose();
        onAdDismissed?.call();
      },
      onAdImpression: (ad) {
        if (kDebugMode) print('📊 Interstitial ad impression recorded');
      },
    );

    try {
      adToShow.show();
      if (kDebugMode) print('🔄 Showing interstitial ad...');
    } catch (e) {
      if (kDebugMode) print('❌ Error showing interstitial ad: $e');
      adToShow.dispose();
      onAdDismissed?.call();
    }
  }

  /// Show Rewarded Ad
  void showRewardedAd(
    RewardedAd? ad, {
    required Function(AdWithoutView ad, RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdDismissed,
  }) {
    if (ad == null) {
      if (kDebugMode) print('⚠️ Rewarded ad is not ready yet');
      onAdDismissed?.call();
      return;
    }

    // Store a local reference to the ad
    final adToShow = ad;

    // Set callbacks first before showing the ad
    adToShow.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        if (kDebugMode) print('✅ Rewarded ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        if (kDebugMode) print('ℹ️ Rewarded ad dismissed');
        ad.dispose();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) print('❌ Rewarded ad failed to show: $error');
        ad.dispose();
        onAdDismissed?.call();
      },
      onAdImpression: (ad) {
        if (kDebugMode) print('📊 Rewarded ad impression recorded');
      },
    );

    try {
      adToShow.show(onUserEarnedReward: onUserEarnedReward);
      if (kDebugMode) print('🔄 Showing rewarded ad...');
    } catch (e) {
      if (kDebugMode) print('❌ Error showing rewarded ad: $e');
      adToShow.dispose();
      onAdDismissed?.call();
    }
  }
}
