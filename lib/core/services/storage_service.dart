import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageKeys {
  // Onboarding keys
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String onboardingCompleted = 'onboarding_completed';

  // Language keys
  static const String selectedLanguage = 'selected_language';
  static const String languageCode = 'language_code';
  static const String countryCode = 'country_code';

  // User preferences
  static const String userTheme = 'user_theme';
  static const String userNotifications = 'user_notifications';
  static const String userProgress = 'user_progress';
  static const String userId = 'user_id';

  // Note: All test statistics are now stored in backend API
  // No local test statistics storage needed

  // App settings
  static const String appVersion = 'app_version';
  static const String firstLaunch = 'first_launch';
  static const String lastSync = 'last_sync';
}

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  StorageService._();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Secure Storage Methods
  Future<void> setSecureString(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecureString(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> setSecureBool(String key, bool value) async {
    await _secureStorage.write(key: key, value: value.toString());
  }

  Future<bool?> getSecureBool(String key) async {
    final value = await _secureStorage.read(key: key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  Future<void> setSecureInt(String key, int value) async {
    await _secureStorage.write(key: key, value: value.toString());
  }

  Future<int?> getSecureInt(String key) async {
    final value = await _secureStorage.read(key: key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> removeSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  // SharedPreferences Methods (for non-sensitive data)
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  double? getDouble(String key) {
    return _prefs?.getDouble(key);
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }

  // Convenience methods for common use cases
  Future<bool> hasSeenOnboarding() async {
    return await getSecureBool(StorageKeys.hasSeenOnboarding) ?? false;
  }

  Future<void> setOnboardingCompleted() async {
    await setSecureBool(StorageKeys.hasSeenOnboarding, true);
    await setSecureBool(StorageKeys.onboardingCompleted, true);
  }

  Future<String> getSelectedLanguage() async {
    return await getSecureString(StorageKeys.selectedLanguage) ?? 'en';
  }

  Future<void> setSelectedLanguage(String languageCode) async {
    await setSecureString(StorageKeys.selectedLanguage, languageCode);
    await setSecureString(StorageKeys.languageCode, languageCode);
  }

  Future<bool> isFirstLaunch() async {
    return await getSecureBool(StorageKeys.firstLaunch) ?? true;
  }

  Future<void> setFirstLaunchCompleted() async {
    await setSecureBool(StorageKeys.firstLaunch, false);
  }

  Future<String> getUserTheme() async {
    return await getSecureString(StorageKeys.userTheme) ?? 'system';
  }

  Future<void> setUserTheme(String theme) async {
    await setSecureString(StorageKeys.userTheme, theme);
  }

  Future<String?> getUserId() async {
    return await getSecureString(StorageKeys.userId);
  }

  Future<void> setUserId(String userId) async {
    await setSecureString(StorageKeys.userId, userId);
  }

  // Note: All test statistics are now managed by TestStatisticsService
  // and stored in backend API - no local storage needed

  // Note: Test statistics methods removed - all handled by backend API
}
