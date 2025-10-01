import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final Locale locale;

  LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.locale,
  });
}

class AppLanguages {
  static List<LanguageModel> get supportedLanguages => [
    LanguageModel(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
      locale: const Locale('en', 'US'),
    ),
    LanguageModel(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
      locale: const Locale('hi', 'IN'),
    ),
    LanguageModel(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      flag: '🇪🇸',
      locale: const Locale('es', 'ES'),
    ),
    LanguageModel(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
      locale: const Locale('fr', 'FR'),
    ),
    LanguageModel(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      flag: '🇩🇪',
      locale: const Locale('de', 'DE'),
    ),
    LanguageModel(
      code: 'zh',
      name: 'Chinese',
      nativeName: '中文',
      flag: '🇨🇳',
      locale: const Locale('zh', 'CN'),
    ),
    LanguageModel(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      flag: '🇯🇵',
      locale: const Locale('ja', 'JP'),
    ),
    LanguageModel(
      code: 'ko',
      name: 'Korean',
      nativeName: '한국어',
      flag: '🇰🇷',
      locale: const Locale('ko', 'KR'),
    ),
    LanguageModel(
      code: 'ta',
      name: 'Tamil',
      nativeName: 'தமிழ்',
      flag: '🇮🇳',
      locale: const Locale('ta', 'IN'),
    ),
  ];

  static LanguageModel getLanguageByCode(String code) {
    return supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages.first, // Default to English
    );
  }

  static LanguageModel get defaultLanguage => supportedLanguages.first;
}

class LocalizationService extends GetxService {
  static LocalizationService get to => Get.find();

  final Rx<LanguageModel> _currentLanguage = AppLanguages.defaultLanguage.obs;
  LanguageModel get currentLanguage => _currentLanguage.value;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() async {
    // This will be called after storage service is initialized
    // For now, use default language
  }

  void changeLanguage(LanguageModel language) {
    _currentLanguage.value = language;
    Get.updateLocale(language.locale);
  }

  void changeLanguageByCode(String code) {
    final language = AppLanguages.getLanguageByCode(code);
    changeLanguage(language);
  }

  List<LanguageModel> get availableLanguages => AppLanguages.supportedLanguages;
}
