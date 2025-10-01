class AppConfig {
  // Environment configuration
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  // API Configuration
  static const String _devBaseUrl = 'http://192.168.31.86:5432/api';
  static const String _prodBaseUrl = 'https://your-production-api.com/api';
  static const String _testBaseUrl = 'http://192.168.31.86:5432/api';

  // Image URL Configuration
  static const String _devImageUrl = 'http://192.168.0.5:5432/uploads';
  static const String _prodImageUrl = 'https://your-production-api.com/uploads';
  static const String _testImageUrl = 'http://localhost:5432/uploads';

  // Database Configuration (for local storage if needed)
  static const String _devDbName = 'aptimaster_dev.db';
  static const String _prodDbName = 'aptimaster_prod.db';
  static const String _testDbName = 'aptimaster_test.db';

  // Get current configuration based on environment
  static String get baseUrl {
    switch (environment) {
      case 'production':
        return _prodBaseUrl;
      case 'test':
        return _testBaseUrl;
      default:
        return _devBaseUrl;
    }
  }

  static String get imageUrl {
    switch (environment) {
      case 'production':
        return _prodImageUrl;
      case 'test':
        return _testImageUrl;
      default:
        return _devImageUrl;
    }
  }

  static String get dbName {
    switch (environment) {
      case 'production':
        return _prodDbName;
      case 'test':
        return _testDbName;
      default:
        return _devDbName;
    }
  }

  // API Timeout Configuration
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // Upload Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
  ];
  static const List<String> allowedVideoTypes = ['video/mp4', 'video/avi'];
  static const List<String> allowedAudioTypes = ['audio/mp3', 'audio/wav'];

  // App Configuration
  static const String appName = 'AptiMaster';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableAds = true; // Control ad visibility

  // Debug Configuration
  static const bool enableDebugLogs = environment == 'development';
  static const bool enableNetworkLogs = environment == 'development';
  static const bool enablePerformanceLogs = environment == 'development';

  // Visibility Configuration
  static const bool showSensitiveInfo = false; // Hide sensitive info in logs
  static const bool showApiUrls = environment == 'development'; // Show API URLs in UI
  static const bool showDebugInfo = environment == 'development'; // Show debug info
}
