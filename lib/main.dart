import 'package:aptimaster/core/controllers/theme_controller.dart';
import 'package:aptimaster/core/services/admob_service.dart';
import 'package:aptimaster/core/services/admob_manager.dart';
import 'package:aptimaster/core/services/api_service.dart';
import 'package:aptimaster/core/services/localization_service.dart';
import 'package:aptimaster/core/services/storage_service.dart';
import 'package:aptimaster/core/services/notification_service.dart';
import 'package:aptimaster/core/theme/app_theme.dart';
import 'package:aptimaster/feature/home/view/home_page.dart';
import 'package:aptimaster/feature/home/view/subcategories_page.dart';
import 'package:aptimaster/feature/language/view/language_selection_screen.dart';
import 'package:aptimaster/feature/onboarding/view/onboarding_screen.dart';
import 'package:aptimaster/feature/profile/view/profile_page.dart';
import 'package:aptimaster/feature/splash/view/splash_screen.dart';
import 'package:aptimaster/feature/statistics/view/statistics_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  // Handle background message here
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize services
  await StorageService.instance.init();

  // Initialize AdMob
  await AdMobService.instance.initialize();

  // Initialize and preload interstitial ads
  await AdMobManager().loadInterstitialAd();

  // Reset and initialize API service to ensure latest configuration
  ApiService.reset();
  ApiService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(ThemeController());
    Get.put(LocalizationService());
    Get.put(NotificationService());

    return GetMaterialApp(
      title: 'AptiMaster',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Localization
      locale: Get.find<LocalizationService>().currentLanguage.locale,
      fallbackLocale: const Locale('en', 'US'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: Get.find<LocalizationService>().availableLanguages
          .map((lang) => lang.locale)
          .toList(),

      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => OnboardingScreen()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(name: '/subcategories', page: () => const SubcategoriesPage()),
        GetPage(name: '/language', page: () => const LanguageSelectionScreen()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(name: '/statistics', page: () => const StatisticsPage()),
      ],
    );
  }
}
