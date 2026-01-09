import 'package:dio/dio.dart';
import 'package:gen_confi/core/config/api_config.dart';
import 'package:gen_confi/core/storage/token_storage.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _initializeDio();
  }

  void _initializeDio() {
    // Read baseUrl dynamically each time (not cached)
    final baseUrl = ApiConfig.baseUrl;
    ApiConfig.printConfig();
    print('🔧 [DioClient] Initializing with baseUrl: $baseUrl');

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  /// Update base URL dynamically (useful for testing or configuration changes)
  void updateBaseUrl(String newBaseUrl) {
    print('🔄 [DioClient] Updating baseUrl to: $newBaseUrl');
    _dio.options.baseUrl = newBaseUrl;
  }

  void _setupInterceptors() {
    // Request interceptor - Add token to headers and ensure baseUrl is current
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // CRITICAL: Always use current baseUrl (in case it changed)
          final currentBaseUrl = ApiConfig.baseUrl;
          if (options.baseUrl != currentBaseUrl) {
            print('🔄 [DioClient Interceptor] Updating baseUrl from ${options.baseUrl} to $currentBaseUrl');
            options.baseUrl = currentBaseUrl;
          }
          
          // Get token from storage
          final token = await TokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 Unauthorized - Token expired
          if (error.response?.statusCode == 401) {
            // Clear token and user data
            await TokenStorage.clearAll();
            // You can navigate to login screen here if needed
          }
          return handler.next(error);
        },
      ),
    );

    // Logging interceptor (only in debug mode)
    // Logging interceptor (only in debug mode)
    // _dio.interceptors.add(
    //   LogInterceptor(
    //     requestBody: true,
    //     responseBody: true,
    //     error: true,
    //     requestHeader: true,
    //     responseHeader: false,
    //   ),
    // );
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      // Ensure baseUrl is current (in case it changed)
      final currentBaseUrl = ApiConfig.baseUrl;
      if (_dio.options.baseUrl != currentBaseUrl) {
        print('🔄 [DioClient] BaseUrl changed, updating from ${_dio.options.baseUrl} to $currentBaseUrl');
        _dio.options.baseUrl = currentBaseUrl;
      }
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      // ALWAYS use current baseUrl (don't rely on cached value)
      final currentBaseUrl = ApiConfig.baseUrl;
      if (_dio.options.baseUrl != currentBaseUrl) {
        print('🔄 [DioClient] BaseUrl mismatch detected!');
        print('   Old: ${_dio.options.baseUrl}');
        print('   New: $currentBaseUrl');
        print('   Updating...');
        _dio.options.baseUrl = currentBaseUrl;
      }
      
      // Debug: Print the full URL being used (verify it's correct)
      final fullUrl = '${_dio.options.baseUrl}$path';
      print('🌐 [DioClient] Making POST request to: $fullUrl');
      print('   Current baseUrl from ApiConstants: $currentBaseUrl');
      
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      // Ensure baseUrl is current (in case it changed)
      final currentBaseUrl = ApiConfig.baseUrl;
      if (_dio.options.baseUrl != currentBaseUrl) {
        print('🔄 [DioClient] BaseUrl changed, updating from ${_dio.options.baseUrl} to $currentBaseUrl');
        _dio.options.baseUrl = currentBaseUrl;
      }
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      // Ensure baseUrl is current (in case it changed)
      final currentBaseUrl = ApiConfig.baseUrl;
      if (_dio.options.baseUrl != currentBaseUrl) {
        print('🔄 [DioClient] BaseUrl changed, updating from ${_dio.options.baseUrl} to $currentBaseUrl');
        _dio.options.baseUrl = currentBaseUrl;
      }
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  String _handleError(DioException error) {
    String errorMessage = 'An error occurred';

    // Print error details to terminal for easier debugging
    final statusCode = error.response?.statusCode;
    final fullUrl = '${error.requestOptions.baseUrl}${error.requestOptions.path}';
    
    print('');
    print('❌ API Error: [${statusCode ?? "Connection Failed"}] ${error.requestOptions.path}');
    print('   Full URL: $fullUrl');
    print('   Error Type: ${error.type}');
    print('   Error Message: ${error.message ?? "No message"}');
    if (error.error != null) {
      print('   Dio Error: ${error.error}');
    }
    if (error.response?.data != null) {
      print('   Response Data: ${error.response?.data}');
    }
    print('');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage =
            'Connection timeout. Please check your internet and try again.';
        break;
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null) {
          final data = response.data;

          if (data is Map) {
            // Priority 1: 'detail' as string
            if (data['detail'] is String) {
              errorMessage = data['detail'];
            }
            // Priority 2: 'message' as string (some backends use this)
            else if (data['message'] is String) {
              errorMessage = data['message'];
            }
            // Priority 3: FastAPI Validation Errors (detail is a list)
            else if (data['detail'] is List) {
              final List details = data['detail'];
              if (details.isNotEmpty && details[0] is Map) {
                errorMessage = details[0]['msg'] ?? 'Validation error';
              } else {
                errorMessage = 'Invalid input provided';
              }
            }
          } else if (data is String && data.isNotEmpty) {
            // Handle plain text or HTML error responses
            if (data.contains('<!DOCTYPE html>')) {
              errorMessage =
                  'Server error: Received HTML instead of JSON. (404/500)';
            } else {
              errorMessage = data;
            }
          } else {
            errorMessage = 'Server error: ${response.statusCode}';
          }
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        errorMessage =
            'Connection error. Please check if the server is running and accessible.';
        break;
      default:
        errorMessage = 'An unexpected error occurred: ${error.message}';
    }

    return errorMessage;
  }
}
