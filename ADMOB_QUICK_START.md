# 🚀 AdMob Quick Start Guide

## Current Status: ✅ READY FOR TESTING

Your app is configured with **Google test ads** and ready to run!

---

## 🎯 Quick Test (Right Now)

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

3. **Check these pages for ads:**
   - ✅ Home Page (bottom banner)
   - ✅ Profile Page (bottom banner)
   - ✅ Statistics Page (bottom banner)

**That's it!** You should see test ads with "Test Ad" labels.

---

## 📝 Before Publishing (Production Setup)

### 1️⃣ Get Your AdMob IDs (15 minutes)

1. Go to [admob.google.com](https://admob.google.com)
2. Create account / Sign in
3. Add your app:
   - **Android**: Package `com.dhigrowth.aptimaster`
   - **iOS**: Bundle `com.dhigrowth.aptimaster`
4. Create ad units:
   - Banner ad (for each platform)
   - Interstitial ad (optional)
   - Rewarded ad (optional)
5. Copy all IDs

### 2️⃣ Update 3 Files

#### File 1: `android/app/src/main/AndroidManifest.xml`
```xml
<!-- Line 42: Replace test ID with your Android App ID -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YOUR_ANDROID_APP_ID_HERE" />
```

#### File 2: `ios/Runner/Info.plist`
```xml
<!-- Line 50: Replace test ID with your iOS App ID -->
<key>GADApplicationIdentifier</key>
<string>YOUR_IOS_APP_ID_HERE</string>
```

#### File 3: `lib/core/services/admob_service.dart`
```dart
// Lines 14-19: Replace with your ad unit IDs
static const String _prodBannerAdUnitIdAndroid = 'YOUR_ANDROID_BANNER_ID';
static const String _prodBannerAdUnitIdIOS = 'YOUR_IOS_BANNER_ID';
static const String _prodInterstitialAdUnitIdAndroid = 'YOUR_ANDROID_INTERSTITIAL_ID';
static const String _prodInterstitialAdUnitIdIOS = 'YOUR_IOS_INTERSTITIAL_ID';
static const String _prodRewardedAdUnitIdAndroid = 'YOUR_ANDROID_REWARDED_ID';
static const String _prodRewardedAdUnitIdIOS = 'YOUR_IOS_REWARDED_ID';

// Line 22: Switch to production
static const bool _useTestAds = false;  // Change to false
```

### 3️⃣ Build & Publish
```bash
# Android
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 🎨 Ad Locations (User-Friendly)

All ads are placed at the **bottom of screens** to avoid disrupting user experience:

- **Home Page**: Below category list
- **Profile Page**: Below menu items
- **Statistics Page**: Below charts

Ads automatically:
- ✅ Show loading indicator while loading
- ✅ Hide if they fail to load (no blank spaces)
- ✅ Dispose when page closes (no memory leaks)

---

## 🔍 Troubleshooting

### No ads showing?
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Check console for:
- `✅ AdMob initialized successfully` - Good!
- `✅ Banner ad loaded successfully` - Good!
- `❌ Banner ad failed to load` - Check internet connection

### Still not working?
See detailed guide: `ADMOB_SETUP_GUIDE.md`

---

## ⚠️ Important Rules

1. **Never click your own ads** (violates AdMob policy)
2. **Use test ads during development** (already configured)
3. **Switch to production IDs before publishing**

---

## 📚 Files Reference

- **AdMob Service**: `lib/core/services/admob_service.dart`
- **Banner Widget**: `lib/core/widgets/banner_ad_widget.dart`
- **Android Config**: `android/app/src/main/AndroidManifest.xml`
- **iOS Config**: `ios/Runner/Info.plist`
- **Detailed Guide**: `ADMOB_SETUP_GUIDE.md`

---

## 🎉 You're All Set!

Your app is ready to display ads. Test it now with:
```bash
flutter run
```

For production setup, follow the 3 steps above when you're ready to publish.

**Questions?** Check `ADMOB_SETUP_GUIDE.md` for detailed instructions.
