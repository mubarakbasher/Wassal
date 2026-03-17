import 'dart:async';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration baseDelay;

  static const _retryableTypes = {
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  };

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(seconds: 2),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final attempt = (extra['_retryAttempt'] as int?) ?? 0;

    if (!_shouldRetry(err, attempt)) {
      return super.onError(err, handler);
    }

    final nextAttempt = attempt + 1;
    final delay = baseDelay * nextAttempt;

    await Future.delayed(delay);

    try {
      err.requestOptions.extra['_retryAttempt'] = nextAttempt;
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return super.onError(e, handler);
    }
  }

  bool _shouldRetry(DioException err, int attempt) {
    if (attempt >= maxRetries) return false;
    if (!_retryableTypes.contains(err.type)) return false;

    final method = err.requestOptions.method.toUpperCase();

    // GET/HEAD are always safe to retry
    if (method == 'GET' || method == 'HEAD') return true;

    // For mutating requests, only retry if the request never reached the server
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}
