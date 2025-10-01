// Environment configuration for API and app behavior

enum AppEnvironment { development, production }

class Environment {
  final String apiBaseUrl;
  final Duration timeoutDuration;
  final bool enableDebugMode;
  final bool enableLogging;
  final bool verifySSL;
  final String environmentName;

  const Environment({
    required this.apiBaseUrl,
    required this.timeoutDuration,
    required this.enableDebugMode,
    required this.enableLogging,
    required this.verifySSL,
    required this.environmentName,
  });
}

class EnvironmentConfig {
  static final Environment development = Environment(
    apiBaseUrl: "https://api-dev.example.com",
    timeoutDuration: const Duration(seconds: 30),
    enableDebugMode: true,
    enableLogging: true,
    verifySSL: true,
    environmentName: "development",
  );

  static final Environment production = Environment(
    apiBaseUrl: "https://api.example.com",
    timeoutDuration: const Duration(seconds: 30),
    enableDebugMode: false,
    enableLogging: false,
    verifySSL: true,
    environmentName: "production",
  );

  // TODO: Switch this based on build flavor/vars if needed
  static Environment current = production;

  // Convenience getters
  static String get apiBaseUrl => current.apiBaseUrl;
  static Duration get timeoutDuration => current.timeoutDuration;
  static bool get enableLogging => current.enableLogging;
  static bool get verifySSL => current.verifySSL;
  static String get environmentName => current.environmentName;
}

