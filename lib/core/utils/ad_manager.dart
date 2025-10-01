import 'package:aptimaster/core/config/app_config.dart';

/// Manages ad frequency and timing to ensure good user experience
/// Controls when and how often ads are shown
class AdManager {
  // Question counter for interstitial ads
  static int _questionCount = 0;

  // Last time an interstitial ad was shown
  static DateTime? _lastInterstitialTime;

  // Configuration
  static const int questionsBeforeAd = 5; // Show ad every 5 questions
  static const int minSecondsBetweenAds = 60; // Minimum 60 seconds between ads

  /// Check if we should show an interstitial ad
  /// Returns true if enough questions have been answered and enough time has passed
  static bool shouldShowInterstitial() {
    // Check if ads are enabled in config
    if (!AppConfig.enableAds) {
      print('🚫 Ads are disabled in AppConfig');
      return false;
    }

    _questionCount++;

    print('📊 Ad Manager: Question count = $_questionCount');

    // Check if we've answered enough questions
    if (_questionCount < questionsBeforeAd) {
      print('⏳ Not enough questions answered yet');
      return false;
    }

    // Check if enough time has passed since last ad
    if (_lastInterstitialTime != null) {
      final timeDiff = DateTime.now().difference(_lastInterstitialTime!);
      if (timeDiff.inSeconds < minSecondsBetweenAds) {
        print(
          '⏳ Not enough time passed since last ad (${timeDiff.inSeconds}s / ${minSecondsBetweenAds}s)',
        );
        return false;
      }
    }

    // Reset counter and update last ad time
    _questionCount = 0;
    _lastInterstitialTime = DateTime.now();

    print('✅ Conditions met - showing interstitial ad');
    return true;
  }

  /// Reset the question counter (call when starting a new test)
  static void resetQuestionCount() {
    _questionCount = 0;
    print('🔄 Ad Manager: Question count reset');
  }

  /// Force reset all ad timers (useful for testing)
  static void resetAll() {
    _questionCount = 0;
    _lastInterstitialTime = null;
    print('🔄 Ad Manager: All timers reset');
  }

  /// Get current question count (for debugging)
  static int get currentQuestionCount => _questionCount;

  /// Get time since last ad (for debugging)
  static Duration? get timeSinceLastAd {
    if (_lastInterstitialTime == null) return null;
    return DateTime.now().difference(_lastInterstitialTime!);
  }
}
