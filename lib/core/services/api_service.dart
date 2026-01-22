// API Service - Centralized Network Layer
// 
// Handles all HTTP requests using Dio:
// - Base URL configuration
// - Auth token interceptor (auto-inject Bearer token)
// - Request/Response logging
// - Error handling with retry logic for 401
// - Cancel tokens for long-running requests
// 
// TODO: Change baseUrl to your production API
// TODO: Implement refresh token logic in _handleAuthError if your API supports it

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'storage_service.dart';

class ApiService extends GetxService {
  late Dio _dio;
  final StorageService _storage = Get.find<StorageService>();
  
  // TODO: Change this base URL to your production API
  static const String baseUrl = 'https://hardware.rektech.work/api/v1';
  
  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
  
  // Cancel tokens map for managing requests
  final Map<String, CancelToken> _cancelTokens = {};
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(milliseconds: connectTimeout),
      receiveTimeout: const Duration(milliseconds: receiveTimeout),
      sendTimeout: const Duration(milliseconds: sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }
  
  /// Setup Dio interceptors for auth, logging, and error handling
  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Auto-inject auth token if available
        final token = _storage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Log request (debug only)
        _logRequest(options);
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response (debug only)
        _logResponse(response);
        
        return handler.next(response);
      },
      onError: (error, handler) async {
        // Log error
        _logError(error);
        
        // Handle 401 Unauthorized - attempt token refresh
        if (error.response?.statusCode == 401) {
          final retried = await _handleAuthError(error, handler);
          if (retried) return;
        }
        
        return handler.next(error);
      },
    ));
  }
  
  /// Handle 401 errors - attempt token refresh or logout
  Future<bool> _handleAuthError(DioException error, ErrorInterceptorHandler handler) async {
    // TODO: Implement refresh token logic here if your API supports it
    // Example:
    // final refreshToken = _storage.getRefreshToken();
    // if (refreshToken != null) {
    //   try {
    //     final response = await _dio.post('/refresh', data: {'refresh_token': refreshToken});
    //     final newToken = response.data['token'];
    //     await _storage.saveToken(newToken);
    //     
    //     // Retry the original request
    //     final opts = error.requestOptions;
    //     opts.headers['Authorization'] = 'Bearer $newToken';
    //     final retryResponse = await _dio.fetch(opts);
    //     return handler.resolve(retryResponse);
    //   } catch (e) {
    //     // Refresh failed, logout user
    //     await _forceLogout();
    //   }
    // }
    
    // For now, just force logout on 401
    await _forceLogout();
    return false;
  }
  
  /// Force logout and redirect to login
  Future<void> _forceLogout() async {
    await _storage.clearAuthData();
    Get.offAllNamed('/login');
    Get.snackbar(
      'Session Expired',
      'Please login again',
      snackPosition: SnackPosition.TOP,
    );
  }
  
  /// Log request details (debug)
  void _logRequest(RequestOptions options) {
    print('┌─────────────────────────────────────────────────────────');
    print('│ REQUEST: ${options.method} ${options.uri}');
    print('│ Headers: ${options.headers}');
    if (options.data != null) {
      print('│ Body: ${options.data}');
    }
    print('└─────────────────────────────────────────────────────────');
  }
  
  /// Log response details (debug)
  void _logResponse(Response response) {
    print('┌─────────────────────────────────────────────────────────');
    print('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    print('│ Data: ${response.data}');
    print('└─────────────────────────────────────────────────────────');
  }
  
  /// Log error details
  void _logError(DioException error) {
    print('┌─────────────────────────────────────────────────────────');
    print('│ ERROR: ${error.type} ${error.requestOptions.uri}');
    print('│ Message: ${error.message}');
    print('│ Response: ${error.response?.data}');
    print('└─────────────────────────────────────────────────────────');
  }
  
  // ============ CANCEL TOKEN MANAGEMENT ============
  
  /// Get or create a cancel token for a request
  CancelToken getCancelToken(String tag) {
    _cancelTokens[tag]?.cancel('Cancelled');
    _cancelTokens[tag] = CancelToken();
    return _cancelTokens[tag]!;
  }
  
  /// Cancel a specific request by tag
  void cancelRequest(String tag) {
    _cancelTokens[tag]?.cancel('Request cancelled by user');
    _cancelTokens.remove(tag);
  }
  
  /// Cancel all pending requests
  void cancelAllRequests() {
    for (var token in _cancelTokens.values) {
      token.cancel('All requests cancelled');
    }
    _cancelTokens.clear();
  }
  
  // ============ HTTP METHODS ============
  
  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  /// Handle Dio errors and return user-friendly messages
  Exception _handleDioError(DioException error) {
    String message;
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server is taking too long to respond. Please try again.';
        break;
      case DioExceptionType.badResponse:
        message = _handleBadResponse(error.response);
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network.';
        break;
      default:
        message = 'Something went wrong. Please try again.';
    }
    
    return ApiException(message, error.response?.statusCode);
  }
  
  /// Handle bad response errors
  String _handleBadResponse(Response? response) {
    if (response == null) return 'Unknown error occurred.';
    
    switch (response.statusCode) {
      case 400:
        return _extractErrorMessage(response.data) ?? 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Resource not found.';
      case 422:
        return _extractValidationErrors(response.data) ?? 'Validation error.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return _extractErrorMessage(response.data) ?? 'Error: ${response.statusCode}';
    }
  }
  
  /// Extract error message from response data
  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? data['msg'];
    }
    return null;
  }
  
  /// Extract validation errors from response
  String? _extractValidationErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] != null) {
      final errors = data['errors'] as Map<String, dynamic>;
      final messages = <String>[];
      errors.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          messages.add(value.first.toString());
        }
      });
      return messages.isNotEmpty ? messages.join('\n') : null;
    }
    return _extractErrorMessage(data);
  }
}

/// Custom API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => message;
}
