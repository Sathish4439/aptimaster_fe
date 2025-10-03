import 'dart:io';
import 'dart:ui';
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

  // Production Ad Unit IDs (replace with your actual AdMob IDs)
  // TODO: Replace these with your actual AdMob ad unit IDs from Google AdMob console
  static const String _prodBannerAdUnitIdAndroid =
      'ca-app-pub-3551669458380838/9557136529';
  static const String _prodBannerAdUnitIdIOS =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodInterstitialAdUnitIdAndroid =
      'ca-app-pub-3551669458380838/5889354254';
  static const String _prodInterstitialAdUnitIdIOS =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodRewardedAdUnitIdAndroid =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodRewardedAdUnitIdIOS =
      'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';

  // Set this to false when you want to use production ads
  static const bool _useTestAds = false;

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      print('✅ AdMob initialized successfully');
      print('🔧 Using test ads: $_useTestAds');
      print('📱 Banner Ad Unit ID: ${bannerAdUnitId}');
      print('📱 Interstitial Ad Unit ID: ${interstitialAdUnitId}');
    } catch (e) {
      print('❌ Error initializing AdMob: $e');
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

  /// Create a Banner Ad
  BannerAd createBannerAd({
    required AdSize adSize,
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (Ad ad) => print('Ad opened: ${ad.adUnitId}'),
        onAdClosed: (Ad ad) => print('Ad closed: ${ad.adUnitId}'),
      ),
    );
  }

  /// Load an Interstitial Ad
  Future<InterstitialAd?> loadInterstitialAd() async {
    InterstitialAd? interstitialAd;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          print('✅ Interstitial ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('❌ Interstitial ad failed to load: $error');
        },
      ),
    );

    return interstitialAd;
  }

  /// Load a Rewarded Ad
  Future<RewardedAd?> loadRewardedAd() async {
    RewardedAd? rewardedAd;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          print('✅ Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('❌ Rewarded ad failed to load: $error');
        },
      ),
    );

    return rewardedAd;
  }

  /// Show Interstitial Ad
  void showInterstitialAd(InterstitialAd? ad, {VoidCallback? onAdDismissed}) {
    if (ad == null) {
      print('⚠️ Interstitial ad is not ready yet');
      onAdDismissed?.call();
      return;
    }

    // Store a local reference to the ad
    final adToShow = ad;

    // Set callbacks first before showing the ad
    adToShow.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('✅ Interstitial ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('ℹ️ Interstitial ad dismissed');
        ad.dispose();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Interstitial ad failed to show: $error');
        ad.dispose();
        onAdDismissed?.call();
      },
      onAdImpression: (ad) {
        print('📊 Interstitial ad impression recorded');
      },
    );

    try {
      adToShow.show();
      print('🔄 Showing interstitial ad...');
    } catch (e) {
      print('❌ Error showing interstitial ad: $e');
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
      print('⚠️ Rewarded ad is not ready yet');
      onAdDismissed?.call();
      return;
    }

    // Store a local reference to the ad
    final adToShow = ad;

    // Set callbacks first before showing the ad
    adToShow.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('✅ Rewarded ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('ℹ️ Rewarded ad dismissed');
        ad.dispose();
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Rewarded ad failed to show: $error');
        ad.dispose();
        onAdDismissed?.call();
      },
      onAdImpression: (ad) {
        print('📊 Rewarded ad impression recorded');
      },
    );

    try {
      adToShow.show(onUserEarnedReward: onUserEarnedReward);
      print('🔄 Showing rewarded ad...');
    } catch (e) {
      print('❌ Error showing rewarded ad: $e');
      adToShow.dispose();
      onAdDismissed?.call();
    }
  }
}
