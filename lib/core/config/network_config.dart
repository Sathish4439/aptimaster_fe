import 'app_config.dart';

class NetworkConfig {
  // API Configuration
  static String get baseUrl => AppConfig.baseUrl;
  static String get imageUrl => AppConfig.imageUrl;

  // Timeout Configuration
  static Duration get connectTimeout =>
      Duration(milliseconds: AppConfig.connectTimeout);
  static Duration get receiveTimeout =>
      Duration(milliseconds: AppConfig.receiveTimeout);
  static Duration get sendTimeout =>
      Duration(milliseconds: AppConfig.sendTimeout);

  // Headers Configuration
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': '${AppConfig.appName}/${AppConfig.appVersion}',
  };

  // Upload Configuration
  static int get maxFileSize => AppConfig.maxFileSize;
  static List<String> get allowedImageTypes => AppConfig.allowedImageTypes;
  static List<String> get allowedVideoTypes => AppConfig.allowedVideoTypes;
  static List<String> get allowedAudioTypes => AppConfig.allowedAudioTypes;

  // Network Status Configuration
  static const Duration networkCheckInterval = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Debug Configuration
  static bool get enableLogs => AppConfig.enableNetworkLogs;
  static bool get enablePerformanceLogs => AppConfig.enablePerformanceLogs;
}
