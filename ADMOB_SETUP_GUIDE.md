# Google AdMob Integration Guide for AptiMaster

This guide provides step-by-step instructions for setting up and using Google AdMob in your Flutter app.

## 📋 Table of Contents
1. [Overview](#overview)
2. [Setup Steps](#setup-steps)
3. [Testing Ads](#testing-ads)
4. [Production Setup](#production-setup)
5. [Ad Placement](#ad-placement)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

The app now includes Google AdMob integration with:
- **Banner Ads**: Displayed at the bottom of HomePage, ProfilePage, and StatisticsPage
- **Interstitial Ads**: Full-screen ads (service ready, can be triggered on navigation)
- **Rewarded Ads**: Video ads that reward users (service ready, can be used for premium features)

### Files Created/Modified:
- ✅ `lib/core/services/admob_service.dart` - Centralized ad management
- ✅ `lib/core/widgets/banner_ad_widget.dart` - Reusable banner ad widget
- ✅ `lib/main.dart` - AdMob initialization
- ✅ `android/app/src/main/AndroidManifest.xml` - Android configuration
- ✅ `ios/Runner/Info.plist` - iOS configuration
- ✅ `pubspec.yaml` - Added google_mobile_ads dependency

---

## 🚀 Setup Steps

### Step 1: Create Google AdMob Account

1. Go to [Google AdMob Console](https://apps.admob.com/)
2. Sign in with your Google account
3. Click **"Get Started"** if you're new to AdMob

### Step 2: Register Your App

#### For Android:
1. In AdMob console, click **"Apps"** → **"Add App"**
2. Select **"Android"**
3. Enter your app details:
   - App name: **AptiMaster**
   - Package name: **com.dhigrowth.aptimaster**
4. Click **"Add"** and note down your **App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`)

#### For iOS:
1. In AdMob console, click **"Apps"** → **"Add App"**
2. Select **"iOS"**
3. Enter your app details:
   - App name: **AptiMaster**
   - Bundle ID: **com.dhigrowth.aptimaster**
4. Click **"Add"** and note down your **App ID**

### Step 3: Create Ad Units

For each platform, create the following ad units:

#### Banner Ad Unit:
1. Go to your app in AdMob console
2. Click **"Ad units"** → **"Add ad unit"**
3. Select **"Banner"**
4. Name it: **"Home Banner"** or **"Main Banner"**
5. Click **"Create ad unit"**
6. Copy the **Ad unit ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY`)

#### Interstitial Ad Unit (Optional):
1. Click **"Add ad unit"** → **"Interstitial"**
2. Name it: **"Navigation Interstitial"**
3. Copy the **Ad unit ID**

#### Rewarded Ad Unit (Optional):
1. Click **"Add ad unit"** → **"Rewarded"**
2. Name it: **"Premium Feature Reward"**
3. Copy the **Ad unit ID**

### Step 4: Update Configuration Files

#### Update Android Manifest:
Open `android/app/src/main/AndroidManifest.xml` and replace the test App ID:

```xml
<!-- Replace this line -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713" />

<!-- With your actual App ID -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY" />
```

#### Update iOS Info.plist:
Open `ios/Runner/Info.plist` and replace the test App ID:

```xml
<!-- Replace this line -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>

<!-- With your actual App ID -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

#### Update AdMob Service:
Open `lib/core/services/admob_service.dart` and update the production ad unit IDs:

```dart
// Line 14-19: Replace with your actual ad unit IDs
static const String _prodBannerAdUnitIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
static const String _prodBannerAdUnitIdIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
static const String _prodInterstitialAdUnitIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
static const String _prodInterstitialAdUnitIdIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
static const String _prodRewardedAdUnitIdAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
static const String _prodRewardedAdUnitIdIOS = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';

// Line 22: Change to false when ready for production
static const bool _useTestAds = false;  // Set to false for production
```

---

## 🧪 Testing Ads

### Current Setup (Test Mode):
The app is currently configured to use **Google's test ad units**. This is safe for development and testing.

**Test Ad Unit IDs (already configured):**
- Banner: `ca-app-pub-3940256099942544/6300978111`
- Interstitial: `ca-app-pub-3940256099942544/1033173712`
- Rewarded: `ca-app-pub-3940256099942544/5224354917`

### Testing Steps:

1. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the App:**
   ```bash
   flutter run
   ```

3. **Verify Ads Load:**
   - Navigate to **HomePage** - Banner ad should appear at the bottom
   - Navigate to **ProfilePage** - Banner ad should appear at the bottom
   - Navigate to **StatisticsPage** - Banner ad should appear at the bottom

4. **Check Console Logs:**
   Look for these messages:
   ```
   ✅ AdMob initialized successfully
   ✅ Banner ad loaded successfully
   ```

### Important Testing Notes:
- ⚠️ **Never click on your own live ads** - This violates AdMob policies
- ✅ **Always use test ads during development**
- ✅ Test ads show "Test Ad" label
- ✅ You can click test ads without policy violations

---

## 🚀 Production Setup

### Before Publishing to Production:

1. **Update App IDs** (Step 4 above)
2. **Update Ad Unit IDs** in `admob_service.dart`
3. **Switch to Production Mode:**
   ```dart
   // In lib/core/services/admob_service.dart
   static const bool _useTestAds = false;  // Change to false
   ```

4. **Test Production Ads:**
   - Use a test device (add your device ID to AdMob console)
   - Or use AdMob's test device feature

5. **Build Release Version:**
   ```bash
   # Android
   flutter build apk --release
   # or
   flutter build appbundle --release

   # iOS
   flutter build ios --release
   ```

---

## 📍 Ad Placement

### Current Implementation:

#### 1. HomePage (`lib/feature/home/view/home_page.dart`)
- **Location**: Bottom of screen
- **Type**: Banner Ad (320x50)
- **User Experience**: Non-intrusive, doesn't block content

#### 2. ProfilePage (`lib/feature/profile/view/profile_page.dart`)
- **Location**: Bottom of screen
- **Type**: Banner Ad (320x50)
- **User Experience**: Appears after scrolling through profile content

#### 3. StatisticsPage (`lib/feature/statistics/view/statistics_page.dart`)
- **Location**: Bottom of screen
- **Type**: Banner Ad (320x50)
- **User Experience**: Visible after viewing statistics

### Adding Interstitial Ads (Optional):

To show interstitial ads between screens:

```dart
// Example: Show ad when navigating to subcategories
InterstitialAd? _interstitialAd;

// Load the ad
_interstitialAd = await AdMobService.instance.loadInterstitialAd();

// Show when navigating
AdMobService.instance.showInterstitialAd(
  _interstitialAd,
  onAdDismissed: () {
    // Navigate after ad is dismissed
    Get.toNamed('/subcategories');
  },
);
```

### Adding Rewarded Ads (Optional):

To reward users for watching ads:

```dart
// Example: Unlock premium feature after watching ad
RewardedAd? _rewardedAd;

// Load the ad
_rewardedAd = await AdMobService.instance.loadRewardedAd();

// Show and reward
AdMobService.instance.showRewardedAd(
  _rewardedAd,
  onUserEarnedReward: (ad, reward) {
    // User watched the ad, give reward
    print('User earned reward: ${reward.amount} ${reward.type}');
    // Unlock premium feature here
  },
  onAdDismissed: () {
    // Ad closed
  },
);
```

---

## 🔧 Troubleshooting

### Ads Not Showing:

1. **Check Internet Connection**
   - Ads require internet to load

2. **Check Console Logs**
   ```
   ❌ Banner ad failed to load: [error message]
   ```

3. **Common Issues:**
   - **"Ad failed to load: 3"** - No ad inventory (normal in test mode sometimes)
   - **"Ad failed to load: 0"** - Internal error (check App ID configuration)
   - **"Ad failed to load: 1"** - Invalid request (check ad unit IDs)

4. **Verify Configuration:**
   - App ID in AndroidManifest.xml is correct
   - App ID in Info.plist is correct
   - Ad unit IDs in admob_service.dart are correct

5. **Clear Cache and Rebuild:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### AdMob Policy Compliance:

⚠️ **Important Guidelines:**
- Don't click your own ads
- Don't encourage users to click ads
- Don't place ads on non-content pages
- Ensure ads don't cover important content
- Follow [AdMob Program Policies](https://support.google.com/admob/answer/6128543)

### Performance Optimization:

- Banner ads are loaded asynchronously (won't block UI)
- Failed ads are hidden automatically (no blank spaces)
- Ads are disposed properly when widgets are destroyed
- Loading indicators show while ads are loading

---

## 📊 Monitoring Ad Performance

1. **AdMob Console**: [apps.admob.com](https://apps.admob.com/)
   - View impressions, clicks, revenue
   - Monitor fill rate and eCPM
   - Check policy violations

2. **Console Logs**:
   - `✅` = Success
   - `❌` = Error
   - `⚠️` = Warning

---

## 📞 Support

- **AdMob Help**: [support.google.com/admob](https://support.google.com/admob)
- **Flutter AdMob Plugin**: [pub.dev/packages/google_mobile_ads](https://pub.dev/packages/google_mobile_ads)
- **AdMob Policies**: [support.google.com/admob/answer/6128543](https://support.google.com/admob/answer/6128543)

---

## ✅ Checklist Before Publishing

- [ ] Created AdMob account
- [ ] Registered Android app in AdMob
- [ ] Registered iOS app in AdMob
- [ ] Created ad units for both platforms
- [ ] Updated AndroidManifest.xml with production App ID
- [ ] Updated Info.plist with production App ID
- [ ] Updated admob_service.dart with production ad unit IDs
- [ ] Changed `_useTestAds` to `false`
- [ ] Tested ads on real devices
- [ ] Verified ads don't violate policies
- [ ] Built release version
- [ ] Tested release build with ads

---

**Good luck with your ad monetization! 🚀**
