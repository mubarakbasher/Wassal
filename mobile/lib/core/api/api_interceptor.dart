import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<_RetryRequest> _pendingRequests = [];

  ApiInterceptor(this._secureStorage)
      : _dio = Dio(BaseOptions(
          baseUrl: AppConstants.apiBaseUrl,
          connectTimeout: AppConstants.connectTimeout,
          receiveTimeout: AppConstants.receiveTimeout,
        ));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add authorization token to requests
    final token = await _secureStorage.read(key: AppConstants.accessTokenKey);
    
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only try to refresh on 401 and if this isn't already a refresh request
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/refresh') &&
        !err.requestOptions.path.contains('/auth/login')) {
      
      // Try to refresh the token
      final refreshed = await _tryRefreshToken(err.requestOptions);
      if (refreshed) {
        // Retry the original request with the new token
        try {
          final newToken = await _secureStorage.read(key: AppConstants.accessTokenKey);
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (retryError) {
          // Retry failed, fall through to clear tokens
        }
      }

      // Refresh failed — clear all tokens
      await _secureStorage.delete(key: AppConstants.accessTokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);
      await _secureStorage.delete(key: AppConstants.userDataKey);
    }

    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle successful responses
    super.onResponse(response, handler);
  }

  /// Attempt to refresh the access token using the stored refresh token.
  /// Returns true if refresh succeeded.
  Future<bool> _tryRefreshToken(RequestOptions failedRequest) async {
    // If already refreshing, wait for result
    if (_isRefreshing) {
      return false;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) {
        return false;
      }

      final response = await _dio.post(
        AppConstants.refreshEndpoint,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'] as String;
        final newRefreshToken = response.data['refreshToken'] as String;

        // Store the new tokens
        await _secureStorage.write(key: AppConstants.accessTokenKey, value: newAccessToken);
        await _secureStorage.write(key: AppConstants.refreshTokenKey, value: newRefreshToken);

        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}

class _RetryRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;

  _RetryRequest({required this.requestOptions, required this.handler});
}
