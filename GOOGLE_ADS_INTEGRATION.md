# 📱 Google Ads Integration - AptiMaster

## ✅ Integration Complete!

Google AdMob has been successfully integrated into the AptiMaster Flutter app. This document provides all the information you need to configure and manage ads.

---

## 📋 What Has Been Implemented

### ✅ Files Created
1. **`lib/core/config/ad_config.dart`** - Ad configuration with test/production Ad IDs
2. **`lib/core/services/ad_service.dart`** - Ad management service (loading, showing, disposing ads)
3. **`lib/core/utils/ad_manager.dart`** - Ad frequency control (prevents ad spam)

### ✅ Files Modified
1. **`pubspec.yaml`** - Added `google_mobile_ads: ^5.1.0` dependency
2. **`android/app/src/main/AndroidManifest.xml`** - Added AdMob App ID
3. **`android/app/build.gradle.kts`** - Set minSdk to 21 (required by AdMob)
4. **`ios/Runner/Info.plist`** - Added AdMob App ID and SKAdNetwork
5. **`lib/main.dart`** - Initialize AdMob and AdService
6. **`lib/feature/home/view/home_page.dart`** - Added banner ad at bottom
7. **`lib/feature/home/view/subcategories_page.dart`** - Added banner ad at bottom
8. **`lib/feature/questions/view/question_screen.dart`** - Added interstitial ads logic
9. **`lib/feature/profile/view/profile_page.dart`** - Added banner ad at bottom
10. **`lib/feature/statistics/view/statistics_page.dart`** - Added banner ad at bottom

---

## 🎯 Ad Placement Strategy

### **Banner Ads** (Bottom of screens)
- ✅ Home Screen
- ✅ Subcategories Screen
- ✅ Profile Screen
- ✅ Statistics Screen

### **Interstitial Ads** (Full-screen between actions)
- ✅ After every 5 questions answered
- ✅ After completing a test
- ✅ Minimum 60 seconds between ads (prevents spam)

### **Rewarded Ads** (Optional - not yet implemented)
- Can be added for hints, extra time, or premium features

---

## 🔧 Configuration Steps

### **Step 1: Create AdMob Account**
1. Go to https://admob.google.com/
2. Sign in with your Google account
3. Create a new AdMob account
4. Accept terms and conditions

### **Step 2: Register Your App**

#### **For Android:**
1. Click "Apps" → "Add App"
2. Select "Android"
3. Enter app name: **AptiMaster**
4. Package name: `com.aptimaster.app`
5. Copy the **Android App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`)

#### **For iOS:**
1. Click "Apps" → "Add App"
2. Select "iOS"
3. Enter app name: **AptiMaster**
4. Bundle ID: `com.aptimaster.app`
5. Copy the **iOS App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX`)

### **Step 3: Create Ad Units**

Create these ad units in AdMob dashboard:

#### **Android Ad Units:**
1. **Banner Ad**
   - Ad format: Banner
   - Name: "AptiMaster Banner Android"
   - Copy Ad Unit ID: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`

2. **Interstitial Ad**
   - Ad format: Interstitial
   - Name: "AptiMaster Interstitial Android"
   - Copy Ad Unit ID: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`

3. **Rewarded Ad** (Optional)
   - Ad format: Rewarded
   - Name: "AptiMaster Rewarded Android"
   - Copy Ad Unit ID: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`

#### **iOS Ad Units:**
Create the same 3 ad units for iOS (different IDs)

### **Step 4: Update Configuration Files**

#### **Update `lib/core/config/ad_config.dart`:**

```dart
class AdConfig {
  // Set to false when you have real Ad IDs
  static const bool useTesting = false; // ⚠️ CHANGE THIS TO FALSE

  // Replace with your real Android Ad IDs
  static const String _androidBannerId = 'ca-app-pub-YOUR-ANDROID-BANNER-ID';
  static const String _androidInterstitialId = 'ca-app-pub-YOUR-ANDROID-INTERSTITIAL-ID';
  static const String _androidRewardedId = 'ca-app-pub-YOUR-ANDROID-REWARDED-ID';

  // Replace with your real iOS Ad IDs
  static const String _iosBannerId = 'ca-app-pub-YOUR-IOS-BANNER-ID';
  static const String _iosInterstitialId = 'ca-app-pub-YOUR-IOS-INTERSTITIAL-ID';
  static const String _iosRewardedId = 'ca-app-pub-YOUR-IOS-REWARDED-ID';
}
```

#### **Update `android/app/src/main/AndroidManifest.xml`:**

```xml
<!-- Replace with your real Android App ID -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-YOUR-ANDROID-APP-ID~XXXXXXXXXX"/>
```

#### **Update `ios/Runner/Info.plist`:**

```xml
<!-- Replace with your real iOS App ID -->
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-YOUR-IOS-APP-ID~XXXXXXXXXX</string>
```

---

## 🧪 Testing

### **Current Status:**
- ✅ Using **Test Ad IDs** (safe for development)
- ✅ Test ads will show during development
- ✅ No risk of policy violations

### **Test on Real Device:**
1. Run the app on a real Android/iOS device
2. Navigate through the app
3. You should see test ads appear:
   - Banner ads at bottom of screens
   - Interstitial ads after 5 questions
   - Interstitial ad after completing test

### **Important Testing Notes:**
- ⚠️ **Never click your own ads** (even test ads)
- ⚠️ Emulators may not show ads properly
- ⚠️ Test on real devices for accurate results
- ✅ Test ads are clearly labeled as "Test Ad"

---

## 🚀 Production Deployment

### **Before Publishing:**

1. **Update `ad_config.dart`:**
   ```dart
   static const bool useTesting = false; // Set to false
   ```

2. **Add Real Ad IDs:**
   - Replace all placeholder IDs with real AdMob IDs
   - Update both Android and iOS configurations

3. **Test with Real Ads:**
   - Build release version
   - Test on real device
   - Verify ads load correctly
   - Check ad placement and frequency

4. **Submit to Stores:**
   - Upload to Google Play Store
   - Upload to Apple App Store
   - Wait for AdMob approval (1-2 days)

### **Post-Launch:**
- Monitor ad performance in AdMob dashboard
- Check fill rates and eCPM
- Adjust ad frequency if needed
- Review user feedback

---

## 📊 Ad Frequency Control

### **Current Settings:**
- **Questions before ad:** 5 questions
- **Minimum time between ads:** 60 seconds
- **Ad on test completion:** Yes

### **To Modify Frequency:**

Edit `lib/core/utils/ad_manager.dart`:

```dart
class AdManager {
  static const int questionsBeforeAd = 5; // Change this number
  static const int minSecondsBetweenAds = 60; // Change this number
}
```

---

## ⚙️ Ad Configuration Options

### **Enable/Disable Ads:**

Edit `lib/core/config/ad_config.dart`:

```dart
class AdConfig {
  // Global ad settings
  static const bool adsEnabled = true; // Set to false to disable all ads
  static const bool showBannerAds = true; // Disable banner ads
  static const bool showInterstitialAds = true; // Disable interstitial ads
  static const bool showRewardedAds = true; // Disable rewarded ads
}
```

---

## 🔍 Troubleshooting

### **Ads Not Showing:**
1. Check internet connection
2. Verify Ad IDs are correct
3. Wait 1-2 minutes for ads to load
4. Check console for error messages
5. Ensure `useTesting = true` during development

### **"Ad failed to load" Error:**
- Normal during development
- Ads retry automatically after 30 seconds
- Check AdMob dashboard for issues
- Verify app is approved in AdMob

### **Ads Showing Too Frequently:**
- Increase `questionsBeforeAd` value
- Increase `minSecondsBetweenAds` value
- Check user feedback

### **Test Ads Not Showing:**
- Use real device (not emulator)
- Check internet connection
- Verify test Ad IDs are correct
- Wait a few minutes after first launch

---

## 📈 Monitoring & Analytics

### **AdMob Dashboard:**
- View ad impressions
- Check revenue
- Monitor fill rates
- Analyze performance by ad unit

### **Firebase Analytics Integration:**
You can track ad events:
```dart
FirebaseAnalytics.instance.logEvent(
  name: 'ad_impression',
  parameters: {'ad_type': 'banner'},
);
```

---

## ⚠️ Important Policies

### **DO:**
✅ Use test ads during development  
✅ Test on real devices  
✅ Respect user experience  
✅ Follow AdMob policies  
✅ Monitor ad performance  

### **DON'T:**
❌ Click your own ads  
❌ Encourage users to click ads  
❌ Show ads too frequently  
❌ Use fake Ad IDs in production  
❌ Violate AdMob policies  

---

## 📞 Support

### **AdMob Support:**
- https://support.google.com/admob/

### **Flutter Google Mobile Ads:**
- https://pub.dev/packages/google_mobile_ads
- https://developers.google.com/admob/flutter/quick-start

---

## 🎉 Summary

✅ **Google Ads successfully integrated!**  
✅ **Banner ads on 4 screens**  
✅ **Interstitial ads with smart frequency control**  
✅ **Test ads working (safe for development)**  
✅ **Ready for production deployment**  

### **Next Steps:**
1. ✅ Test the app with test ads
2. 📝 Create AdMob account and get real Ad IDs
3. 🔧 Update configuration with real IDs
4. 🚀 Deploy to production
5. 📊 Monitor performance in AdMob dashboard

---

**Happy Monetizing! 💰**
