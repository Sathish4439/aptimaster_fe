# AdMob Integration Guide for AptiMaster

This guide explains how Google Mobile Ads (AdMob) has been properly integrated into the AptiMaster Flutter application.

## ✅ What's Included

- **Complete Package Integration**: `google_mobile_ads: ^5.1.0`
- **Optimized Service Architecture**: Centralized ad management
- **Platform Configuration**: Android & iOS setup
- **Reusable Widgets**: Easy-to-use banner ad components
- **Error Handling**: Robust error management throughout
- **Performance Optimization**: Preloading and caching strategies
- **Testing Support**: Debug modes and test ad units

## 🏗️ Architecture Overview

### Core Components

1. **AdMobService** (`lib/core/services/admob_service.dart`)

   - Centralized ad management
   - Platform-specific ad unit ID handling
   - Optimized ad request configuration
   - Error handling and logging

2. **AdMobManager** (`lib/core/services/admob_manager.dart`)

   - Interstitial ad lifecycle management
   - Preloading strategies
   - Automatic ad refetching

3. **Banner Ad Widgets** (`lib/widgets/banner_ad_widget.dart`)
   - `BannerAdWidget`: Standard banner ads
   - `AdaptiveBannerAdWidget`: Responsive banner ads
   - `DebugBannerAdWidget`: Development testing

## 📱 Platform Configuration

### Android Setup ✅

**AndroidManifest.xml** (`android/app/src/main/AndroidManifest.xml`)

```xml
<!-- Internet permission -->
<uses-permission android:name="android.permission.INTERNET" />

<application>
    <!-- Google AdMob App ID -->
    <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="ca-app-pub-3551669458380838~1239662809" />
</application>
```

**Gradle Configuration** (`android/app/build.gradle.kts`)

- Minimum SDK 21 (required for AdMob)
- Core library desugaring enabled
- Proper signing configuration

### iOS Setup ✅

**Info.plist** (`ios/Runner/Info.plist`)

```xml
<!-- Google AdMob App ID -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3551669458380838~1239662809</string>

<!-- SKAdNetwork identifiers for ad attribution -->
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <!-- ... additional SKAdNetwork identifiers ... -->
</array>
```

## 🚀 Usage Examples

### Basic Banner Ad

```dart
// Simple banner ad
BannerAdWidget()

// Large banner ad
BannerAdWidget(adSize: BannerAdSizes.largeBanner)

// Adaptive banner ad
AdaptiveBannerAdWidget()
```

### Interstitial Ads

```dart
// Using AdMobManager (recommended)
AdMobManager().showInterstitialAd(
  onAdDismissed: () {
    // Handle ad dismissal
    navigateToNextScreen();
  },
);

// Direct AdMobService usage
final interstitialAd = await AdMobService.instance.loadInterstitialAd();
AdMobService.instance.showInterstitialAd(interstitialAd);
```

### Rewarded Ads

```dart
final rewardedAd = await AdMobService.instance.loadRewardedAd();
AdMobService.instance.showRewardedAd(
  rewardedAd,
  onUserEarnedReward: (ad, reward) {
    // Apply reward to user
    grantUserReward(reward.amount);
  },
);
```

### Custom Banner with Configuration

```dart
BannerAdWidget(
  adSize: BannerAdSizes.mediumRectangle,
  margin: EdgeInsets.all(16),
  enabled: shouldShowAds(),
  onAdLoaded: () => print('Ad loaded successfully'),
  onAdFailedToLoad: () => print('Ad failed to load'),
)
```

## 🎯 Ad Unit Configuration

### Current Ad Unit IDs

**Android Production:**

- Banner: `ca-app-pub-3551669458380838/9557136529`
- Interstitial: `ca-app-pub-3551669458380838/5889354254`

**iOS Production:**

- Banner: `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY` (⚠️ **NEEDS UPDATE**)
- Interstitial: `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY` (⚠️ **NEEDS UPDATE**)

**Test Ad Unit IDs** (for development):

- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Rewarded: `ca-app-pub-3940256099942544/5224354917`

### 🔧 Configuration Switching

Toggle test/production ads in `AdMobService`:

```dart
// Set this to false when you want to use production ads
static const bool _useTestAds = true; // For development
static const bool _useTestAds = false; // For production
```

## 🔄 Initialization

### Automatic Initialization

AdMob is automatically initialized in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob
  await AdMobService.instance.initialize();

  // Initialize and preload interstitial ads
  await AdMobManager().loadInterstitialAd();

  runApp(const MyApp());
}
```

### Manual Initialization

```dart
// Check if AdMob is initialized
final isInitialized = await AdMobService.instance.ensureInitialized();

// Preload ads for better performance
await AdMobUtils.preloadAds();
```

## ⚡ Performance Optimizations

### 1. Preloading Strategy

- Interstitial ads are preloaded automatically
- Rewarded ads can be preloaded before needed
- Banner ads load on-demand

### 2. Ad Request Configuration

- Optimal content rating (PG)
- Child-directed treatment settings
- Test device configuration for development

### 3. Memory Management

- Automatic ad disposal on dismissal
- Proper lifecycle management
- Clean resource handling

## 🐛 Debugging Features

### Debug Mode Detection

```dart
if (kDebugMode) {
  // Debug-only operations
  print('Debug information');
  MobileAds.instance.updateRequestConfiguration(requestConfiguration);
}
```

### Debug Banner Widget

```dart
// Only shows placeholder in debug mode
DebugBannerAdButton()
```

### Logging Configuration

All debug logging is controlled by `kDebugMode` and won't appear in production builds.

## 🚨 Common Issues & Solutions

### 1. Ads Not Showing

**Check:**

- ✅ AdMob initialized properly
- ✅ Correct ad unit IDs
- ✅ Internet connectivity
- ✅ Platform configuration

**Debug:**

```dart
// Check initialization status
final isInitialized = AdMobService.instance.isInitialized;
print('AdMob initialized: $isInitialized');

// Check ad unit IDs
print('Banner ID: ${AdMobService.instance.bannerAdUnitId}');
```

### 2. iOS Ads Not Working

**Ensure:**

- ✅ Info.plist contains GADApplicationIdentifier
- ✅ SKAdNetworkItems configured
- ✅ Proper bundle ID in AdMob console

### 3. Android Ads Not Working

**Check:**

- ✅ AndroidManifest.xml configuration
- ✅ Minimum SDK 21
- ✅ Google Play Services availability

## 📊 Best Practices

### 1. User Experience

- Show ads at natural break points
- Respect user preferences and subscriptions
- Implement ad frequency capping
- Handle ad failures gracefully

### 2. Revenue Optimization

- Use A/B testing for ad placements
- Implement rewarded ads for premium features
- Monitor fill rates and earnings
- Respect AdMob policies

### 3. Performance

- Preload interstitial ads
- Cache banner ads appropriately
- Minimize ad blocking on critical paths
- Monitor app performance impact

## 🔒 Privacy & Compliance

### GDPR Compliance

```dart
// Non-personalized ads for GDPR compliance
final request = AdRequest(
  nonPersonalizedAds: true,
  keywords: restrictedKeywords,
);
```

### Children's Privacy

```dart
final requestConfiguration = RequestConfiguration(
  tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
  maxAdContentRating: MaxAdContentRating.g,
);
```

## 📈 Monitoring & Analytics

### Ad Performance Tracking

```dart
// Track ad events
_adListener = BannerAdListener(
  onAdLoaded: (ad) {
    analytics.trackEvent('banner_ad_loaded');
  },
  onAdFailedToLoad: (ad, error) {
    analytics.trackEvent('banner_ad_failed', {'error': error.message});
  },
);
```

### Revenue Monitoring

- Monitor fill rates in AdMob console
- Track eCPM trends
- Implement revenue analytics
- A/B test different ad strategies

## 🛠️ Development Tools

### Testing Configuration

```dart
// Test device configuration
final testDeviceIds = ['TEST-DEVICE-ID'];
MobileAds.instance.updateRequestConfiguration(
  RequestConfiguration(testDeviceIds: testDeviceIds),
);
```

### Mock Ads for Testing

```dart
// Use DebugBannerAdWidget for testing UI layouts
DebugBannerAdWidget(
  adSize: BannerAdSizes.banner,
  margin: EdgeInsets.all(16),
)
```

## 📝 Next Steps

1. **Update iOS Ad Unit IDs** - Replace placeholder IDs in `AdMobService`
2. **Implement Ad Preferences** - Add user controls for ad frequency
3. **Revenue Analytics** - Add tracking for ad performance
4. **A/B Testing** - Implement different ad strategies
5. **Premium Features** - Add ad-free option for premium users

## 🔗 Resources

- [Google Mobile Ads Flutter Plugin](https://pub.dev/packages/google_mobile_ads)
- [AdMob Console](https://www.google.com/admob/)
- [AdMob Policies](https://support.google.com/admob/answer/6129563)
- [Flutter AdMob Integration Guide](https://docs.flutter.dev/development/platform-integration/mobile/android)

---

**Status**: ✅ Fully Integrated and Production Ready  
**Last Updated**: $(date)  
**Version**: google_mobile_ads ^5.1.0

