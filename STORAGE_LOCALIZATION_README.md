# AptiMaster - Storage & Localization System

This Flutter app now includes a comprehensive storage system using Flutter Secure Storage and a complete multilanguage support system. The app supports 8 languages and uses secure storage for sensitive data.

## 🔐 Storage System

### **StorageService Class**

A centralized service that manages both secure and non-secure storage:

#### **Secure Storage (Flutter Secure Storage)**

- **Onboarding status** - `has_seen_onboarding`
- **Language preferences** - `selected_language`, `language_code`
- **User theme** - `user_theme`
- **User progress** - `user_progress`
- **App settings** - `app_version`, `first_launch`

#### **SharedPreferences (Non-sensitive data)**

- **UI preferences** - Theme settings, notification preferences
- **Cache data** - Temporary app data
- **User settings** - Non-sensitive configuration

### **StorageKeys Class**

Centralized constants for all storage keys:

```dart
class StorageKeys {
  // Onboarding keys
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String onboardingCompleted = 'onboarding_completed';

  // Language keys
  static const String selectedLanguage = 'selected_language';
  static const String languageCode = 'language_code';

  // User preferences
  static const String userTheme = 'user_theme';
  static const String userNotifications = 'user_notifications';
}
```

### **Usage Examples**

```dart
// Secure storage
await StorageService.instance.setSecureString('key', 'value');
String? value = await StorageService.instance.getSecureString('key');

// Convenience methods
bool hasSeenOnboarding = await StorageService.instance.hasSeenOnboarding();
await StorageService.instance.setOnboardingCompleted();
String language = await StorageService.instance.getSelectedLanguage();
```

## 🌍 Multilanguage Support

### **Supported Languages**

1. **English** (en) - 🇺🇸 Default
2. **Hindi** (hi) - 🇮🇳 हिन्दी
3. **Spanish** (es) - 🇪🇸 Español
4. **French** (fr) - 🇫🇷 Français
5. **German** (de) - 🇩🇪 Deutsch
6. **Chinese** (zh) - 🇨🇳 中文
7. **Japanese** (ja) - 🇯🇵 日本語
8. **Korean** (ko) - 🇰🇷 한국어

### **LocalizationService**

Manages language switching and persistence:

```dart
// Change language
LocalizationService.to.changeLanguage(language);
LocalizationService.to.changeLanguageByCode('hi');

// Get current language
LanguageModel currentLang = LocalizationService.to.currentLanguage;
List<LanguageModel> availableLangs = LocalizationService.to.availableLanguages;
```

### **TranslationService**

Centralized translation management:

```dart
// Get translation
String text = AppTranslations.translate('welcome');
String localizedText = AppTranslations.translate('welcome', 'hi');

// Get all translations for a language
Map<String, String> translations = AppTranslations.getTranslations('es');
```

## 🎨 Language Selection Screen

### **Features**

- **Beautiful UI** with flag icons and native language names
- **Current language indicator** with highlight
- **Smooth animations** and transitions
- **Instant language switching** with persistence
- **Success feedback** with snackbar notifications

### **Design Elements**

- **Flag icons** for visual language identification
- **Native language names** for better user experience
- **Selected state** with primary color highlighting
- **Check icons** for current selection
- **Responsive layout** for all screen sizes

## 📱 App Integration

### **Main App Setup**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(ThemeController());
    Get.put(LocalizationService());

    return GetMaterialApp(
      // Localization configuration
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
    );
  }
}
```

### **Updated Controllers**

- **OnboardingController** now uses `StorageService` for persistence
- **SplashScreen** checks onboarding status via secure storage
- **ThemeController** can be extended to use storage for theme persistence

## 🔧 Technical Implementation

### **Dependencies Added**

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0 # Secure storage
  flutter_localizations: # Localization support
    sdk: flutter
```

### **File Structure**

```
lib/
├── core/
│   ├── services/
│   │   ├── storage_service.dart      # Storage management
│   │   ├── localization_service.dart # Language management
│   │   └── translation_service.dart  # Translation data
│   └── controllers/
│       └── onboarding_controller.dart # Updated for storage
├── feature/
│   ├── language/
│   │   └── view/
│   │       └── language_selection_screen.dart
│   └── splash/
│       └── view/
│           └── splash_screen.dart    # Updated for storage
└── main.dart                         # Updated for localization
```

### **Security Features**

- **Encrypted storage** for sensitive data
- **Keychain integration** on iOS
- **Android Keystore** integration
- **Automatic encryption/decryption**
- **Secure key management**

## 🚀 Usage Examples

### **Language Switching**

```dart
// In any widget
ElevatedButton(
  onPressed: () {
    Get.toNamed('/language');
  },
  child: Text(AppTranslations.translate('select_language')),
)

// Programmatic language change
LocalizationService.to.changeLanguageByCode('hi');
```

### **Storage Operations**

```dart
// Save user preferences
await StorageService.instance.setUserTheme('dark');
await StorageService.instance.setSelectedLanguage('es');

// Retrieve data
String theme = await StorageService.instance.getUserTheme();
bool isFirstLaunch = await StorageService.instance.isFirstLaunch();
```

### **Translation Usage**

```dart
// In widgets
Text(AppTranslations.translate('welcome'))
Text(AppTranslations.translate('home_welcome'))

// With parameters (future enhancement)
Text(AppTranslations.translate('welcome_user', 'John'))
```

## 🎯 Benefits

### **Storage Benefits**

- **Secure data protection** for sensitive information
- **Centralized storage management** with consistent API
- **Type-safe operations** with proper error handling
- **Easy migration** from SharedPreferences to secure storage
- **Cross-platform compatibility** (iOS Keychain, Android Keystore)

### **Localization Benefits**

- **Global accessibility** with 8 supported languages
- **Native language support** with proper locale handling
- **Easy language switching** with instant updates
- **Consistent translations** across all screens
- **Extensible system** for adding new languages

### **User Experience**

- **Seamless onboarding** with persistent state
- **Language preferences** remembered across app sessions
- **Professional UI** with flag icons and native names
- **Instant feedback** with success notifications
- **Responsive design** for all screen sizes

## 🔮 Future Enhancements

### **Storage**

- **Cloud sync** for user preferences
- **Backup/restore** functionality
- **Data migration** tools
- **Storage analytics** and monitoring

### **Localization**

- **RTL support** for Arabic/Hebrew
- **Dynamic translations** from server
- **Pluralization support** for complex grammar
- **Date/time formatting** per locale
- **Currency formatting** per region

The app now provides a robust foundation for international users with secure data storage and comprehensive language support, making it accessible to a global audience while maintaining data security and user privacy.
