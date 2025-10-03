class NetworkConfig {
  // Base URL
  static const String baseUrl = "https://aptimaster-be-l1xv-ay08bkujb-sathish4439s-projects.vercel.app/api";

  // API Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Retry configurations
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Enable/disable logging
  static const bool enableLogging = false;

  // Enable/disable SSL verification
  static const bool verifySSL = true;

  // Environment name
  static const String environmentName = "production";

  // Check if running in development
  static const bool isDevelopment = false;

  // Check if running in production
  static const bool isProduction = true;
}

// Network constants
class NetworkConstants {
  // HTTP Status Codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusInternalServerError = 500;
  static const int statusServiceUnavailable = 503;

  // Error Messages
  static const String connectionTimeoutError =
      'Connection timeout. Please check your internet connection.';
  static const String noInternetError =
      'No internet connection. Please check your network.';
  static const String serverError =
      'Server error occurred. Please try again later.';
  static const String unknownError = 'An unexpected error occurred.';
  static const String requestCancelledError = 'Request was cancelled.';
  static const String certificateError = 'Certificate error.';
}

// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({required this.success, this.data, this.error, this.statusCode});

  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse(success: true, data: data, statusCode: statusCode);
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse(success: false, error: error, statusCode: statusCode);
  }
}
