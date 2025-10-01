import 'package:aptimaster/core/services/api_endpoints.dart';
import 'package:aptimaster/core/config/network_config.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:developer' as developer;

class ApiService {
  static ApiService? _instance;
  factory ApiService() => _instance ??= ApiService._internal();
  ApiService._internal();

  late Dio _dio;

  void init() {
    _initializeDio();
  }

  // Method to reinitialize with new configuration
  void reinitialize() {
    _initializeDio();
  }

  // Method to reset the singleton instance
  static void reset() {
    _instance = null;
  }

  void _initializeDio() {
    // Debug: Print the base URL being used
    developer.log('🔧 Initializing Dio with baseUrl: ${NetworkConfig.baseUrl}', name: 'ApiService');
    print('📡 API Service - Base URL: ${NetworkConfig.baseUrl}');

    _dio = Dio(
      BaseOptions(
        baseUrl: NetworkConfig.baseUrl,
        connectTimeout: NetworkConfig.connectTimeout,
        receiveTimeout: NetworkConfig.receiveTimeout,
        sendTimeout: NetworkConfig.sendTimeout,
        headers: NetworkConfig.defaultHeaders,
      ),
    );

    // Add interceptors for error handling and logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          developer.log(
            '📤 REQUEST: ${options.method} ${options.path}',
            name: 'ApiService',
          );
          print('📤 ${options.method} ${options.baseUrl}${options.path}');
          if (options.queryParameters.isNotEmpty) {
            print('   Query: ${options.queryParameters}');
          }
          if (options.data != null) {
            print('   Data: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          developer.log(
            '📥 RESPONSE: ${response.statusCode} ${response.requestOptions.path}',
            name: 'ApiService',
          );
          print('📥 ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}');
          print('   Response: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          developer.log(
            '❌ ERROR: ${error.type} ${error.requestOptions.path}',
            name: 'ApiService',
            error: error.message,
          );
          print('❌ ERROR: ${error.type} - ${error.message}');
          if (error.response != null) {
            print('   Status: ${error.response?.statusCode}');
            print('   Data: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );
  }

  // Generic GET method
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      developer.log('🔍 GET Request to: $path', name: 'ApiService');
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      developer.log('✅ GET Success: $path', name: 'ApiService');
      return response;
    } on DioException catch (e) {
      developer.log('❌ GET Failed: $path', name: 'ApiService', error: e);
      throw _handleError(e);
    }
  }

  // Generic POST method
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, File>? files,
  }) async {
    try {
      developer.log('📝 POST Request to: $path', name: 'ApiService');
      dynamic requestData = data;

      // If files are provided, create FormData
      if (files != null && files.isNotEmpty) {
        final formData = FormData();

        // Add regular data fields
        if (data is Map<String, dynamic>) {
          data.forEach((key, value) {
            formData.fields.add(MapEntry(key, value.toString()));
          });
        }

        // Add file fields
        files.forEach((fieldName, file) {
          formData.files.add(
            MapEntry(
              fieldName,
              MultipartFile.fromFileSync(
                file.path,
                filename: file.path.split('/').last,
              ),
            ),
          );
        });

        requestData = formData;
      }

      final response = await _dio.post<T>(
        path,
        data: requestData,
        queryParameters: queryParameters,
        options: options,
      );
      developer.log('✅ POST Success: $path', name: 'ApiService');
      return response;
    } on DioException catch (e) {
      developer.log('❌ POST Failed: $path', name: 'ApiService', error: e);
      throw _handleError(e);
    }
  }

  // Generic PUT method
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    Map<String, File>? files,
  }) async {
    try {
      developer.log('🔄 PUT Request to: $path', name: 'ApiService');
      dynamic requestData = data;

      // If files are provided, create FormData
      if (files != null && files.isNotEmpty) {
        final formData = FormData();

        // Add regular data fields
        if (data is Map<String, dynamic>) {
          data.forEach((key, value) {
            formData.fields.add(MapEntry(key, value.toString()));
          });
        }

        // Add file fields
        files.forEach((fieldName, file) {
          formData.files.add(
            MapEntry(
              fieldName,
              MultipartFile.fromFileSync(
                file.path,
                filename: file.path.split('/').last,
              ),
            ),
          );
        });

        requestData = formData;
      }

      final response = await _dio.put<T>(
        path,
        data: requestData,
        queryParameters: queryParameters,
        options: options,
      );
      developer.log('✅ PUT Success: $path', name: 'ApiService');
      return response;
    } on DioException catch (e) {
      developer.log('❌ PUT Failed: $path', name: 'ApiService', error: e);
      throw _handleError(e);
    }
  }

  // Generic DELETE method
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      developer.log('🗑️ DELETE Request to: $path', name: 'ApiService');
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      developer.log('✅ DELETE Success: $path', name: 'ApiService');
      return response;
    } on DioException catch (e) {
      developer.log('❌ DELETE Failed: $path', name: 'ApiService', error: e);
      throw _handleError(e);
    }
  }

  // FCM Token methods
  Future<String?> createUserWithFCMToken(String fcmToken) async {
    try {
      developer.log('🔔 Creating user with FCM token', name: 'ApiService');
      print('🔔 Creating user with FCM token: $fcmToken');
      final response = await post(
        '/users',
        data: {
          'fcmToken': fcmToken,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final userId = response.data['userId'] ?? response.data['id'];
        developer.log('✅ User created with ID: $userId', name: 'ApiService');
        print('✅ User created successfully: $userId');
        return userId;
      }
      developer.log('⚠️ User creation failed: ${response.statusCode}', name: 'ApiService');
      return null;
    } catch (e) {
      developer.log('❌ Error creating user with FCM token', name: 'ApiService', error: e);
      print('❌ Error creating user: $e');
      return null;
    }
  }

  Future<bool> updateFCMToken(String userId, String fcmToken) async {
    try {
      developer.log('🔔 Updating FCM token for user: $userId', name: 'ApiService');
      print('🔔 Updating FCM token for user: $userId');
      final response = await put(
        '/users/$userId/fcm-token',
        data: {
          'fcmToken': fcmToken,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      final success = response.statusCode == 200;
      if (success) {
        developer.log('✅ FCM token updated successfully', name: 'ApiService');
        print('✅ FCM token updated successfully');
      } else {
        developer.log('⚠️ FCM token update failed: ${response.statusCode}', name: 'ApiService');
        print('⚠️ FCM token update failed: ${response.statusCode}');
      }
      return success;
    } catch (e) {
      developer.log('❌ Error updating FCM token', name: 'ApiService', error: e);
      print('❌ Error updating FCM token: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> uploadAvatar(
    String userId,
    File imageFile,
  ) async {
    try {
      developer.log('📸 Uploading avatar for user: $userId', name: 'ApiService');
      print('📸 Uploading avatar: ${imageFile.path}');
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _dio.post(
        '${_dio.options.baseUrl}/users/$userId/avatar',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        developer.log('✅ Avatar uploaded successfully', name: 'ApiService');
        print('✅ Avatar uploaded successfully');
        return response.data;
      }
      developer.log('⚠️ Avatar upload failed: ${response.statusCode}', name: 'ApiService');
      print('⚠️ Avatar upload failed: ${response.statusCode}');
      return null;
    } catch (e) {
      developer.log('❌ Error uploading avatar', name: 'ApiService', error: e);
      print('❌ Error uploading avatar: $e');
      return null;
    }
  }

  // Error handling
  Exception _handleError(DioException error) {
    developer.log(
      '🚨 Handling DioException: ${error.type}',
      name: 'ApiService',
      error: error.message,
    );
    print('🚨 DioException Type: ${error.type}');
    print('   Message: ${error.message}');
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data?['error'] ?? 'Server error occurred';
        return Exception('Error $statusCode: $message');

      case DioExceptionType.cancel:
        return Exception('Request was cancelled');

      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');

      case DioExceptionType.badCertificate:
        return Exception('Certificate error');

      case DioExceptionType.unknown:
        return Exception('An unexpected error occurred');
    }
  }
}
