import 'dart:io';

/// Configuration for Google AdMob ads
/// Contains Ad Unit IDs for different platforms and ad types
class AdConfig {
  // Set to false when you have real Ad IDs from AdMob
  static const bool useTesting = true; // Using real ads now

  // ============================================
  // ANDROID AD UNIT IDs
  // ============================================

  // Test Banner Ad ID for Android
  static const String _androidTestBannerId =
      'ca-app-pub-3940256099942544/6300978111';

  // Test Interstitial Ad ID for Android
  static const String _androidTestInterstitialId =
      'ca-app-pub-3940256099942544/1033173712';

  // Test Rewarded Ad ID for Android
  static const String _androidTestRewardedId =
      'ca-app-pub-3940256099942544/5224354917';

  // Real Banner Ad ID for Android
  static const String _androidBannerId =
      'ca-app-pub-3551669458380838/9557136529';

  // Real Interstitial Ad ID for Android
  static const String _androidInterstitialId =
      'ca-app-pub-3551669458380838/5889354254';

  // Real Rewarded Ad ID for Android (Replace with your real ID from AdMob)
  // TODO: Get this from https://admob.google.com after creating your app
  static const String _androidRewardedId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // ============================================
  // iOS AD UNIT IDs
  // ============================================

  // Test Banner Ad ID for iOS
  static const String _iosTestBannerId =
      'ca-app-pub-3940256099942544/2934735716';

  // Test Interstitial Ad ID for iOS
  static const String _iosTestInterstitialId =
      'ca-app-pub-3940256099942544/4411468910';

  // Test Rewarded Ad ID for iOS
  static const String _iosTestRewardedId =
      'ca-app-pub-3940256099942544/1712485313';

  // Real Banner Ad ID for iOS (Replace with your real ID)
  static const String _iosBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // Real Interstitial Ad ID for iOS (Replace with your real ID)
  static const String _iosInterstitialId =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // Real Rewarded Ad ID for iOS (Replace with your real ID)
  static const String _iosRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // ============================================
  // PLATFORM-SPECIFIC GETTERS
  // ============================================

  /// Get Banner Ad Unit ID based on platform
  static String get bannerAdUnitId {
    String adId;
    if (Platform.isAndroid) {
      adId = useTesting ? _androidTestBannerId : _androidBannerId;
    } else if (Platform.isIOS) {
      adId = useTesting ? _iosTestBannerId : _iosBannerId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
    print('🎯 Using ${useTesting ? "TEST" : "REAL"} Banner Ad ID: $adId');
    return adId;
  }

  /// Get Interstitial Ad Unit ID based on platform
  static String get interstitialAdUnitId {
    String adId;
    if (Platform.isAndroid) {
      adId = useTesting ? _androidTestInterstitialId : _androidInterstitialId;
    } else if (Platform.isIOS) {
      adId = useTesting ? _iosTestInterstitialId : _iosInterstitialId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
    print('🎯 Using ${useTesting ? "TEST" : "REAL"} Interstitial Ad ID: $adId');
    return adId;
  }

  /// Get Rewarded Ad Unit ID based on platform
  static String get rewardedAdUnitId {
    String adId;
    if (Platform.isAndroid) {
      adId = useTesting ? _androidTestRewardedId : _androidRewardedId;
    } else if (Platform.isIOS) {
      adId = useTesting ? _iosTestRewardedId : _iosRewardedId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
    print('🎯 Using ${useTesting ? "TEST" : "REAL"} Rewarded Ad ID: $adId');
    return adId;
  }

  // ============================================
  // AD CONFIGURATION SETTINGS
  // ============================================

  /// Enable or disable ads globally
  static const bool adsEnabled = true;

  /// Show banner ads
  static const bool showBannerAds = true;

  /// Show interstitial ads
  static const bool showInterstitialAds = true;

  /// Show rewarded ads
  static const bool showRewardedAds = true;

  /// Show verbose ad error logs (useful for debugging)
  static const bool showAdErrorLogs = true;

  /// Retry delay in seconds when ad fails to load
  static const int adRetryDelaySeconds = 30;

  // ============================================
  // AD ERROR MESSAGES
  // ============================================

  /// Get user-friendly error message for ad load errors
  static String getErrorMessage(int errorCode) {
    switch (errorCode) {
      case 0:
        return 'Internal error occurred';
      case 1:
        return 'Invalid ad request';
      case 2:
        return 'Network error';
      case 3:
        return 'No ad available'; // This is your current error
      default:
        return 'Ad failed to load';
    }
  }
}
