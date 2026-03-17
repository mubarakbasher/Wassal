import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

enum NetworkErrorType {
  timeout,
  dnsFailure,
  connectionRefused,
  tlsError,
  networkUnreachable,
  connectionError,
  serverError,
  auth,
  permission,
  notFound,
  cancelled,
  unknown,
}

class ErrorHandler {
  /// Classifies the root cause of a Dio/network error.
  static NetworkErrorType classifyError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkErrorType.timeout;

        case DioExceptionType.connectionError:
          return _classifyConnectionError(e);

        case DioExceptionType.badResponse:
          final code = e.response?.statusCode;
          if (code == 401) return NetworkErrorType.auth;
          if (code == 403) return NetworkErrorType.permission;
          if (code == 404) return NetworkErrorType.notFound;
          return NetworkErrorType.serverError;

        case DioExceptionType.cancel:
          return NetworkErrorType.cancelled;

        default:
          return _classifyByInnerError(e.error);
      }
    }
    return NetworkErrorType.unknown;
  }

  static NetworkErrorType _classifyConnectionError(DioException e) {
    final inner = e.error;
    return _classifyByInnerError(inner);
  }

  static NetworkErrorType _classifyByInnerError(dynamic inner) {
    if (inner is SocketException) {
      final msg = inner.message.toLowerCase();
      if (msg.contains('failed host lookup') || msg.contains('no address associated')) {
        return NetworkErrorType.dnsFailure;
      }
      if (msg.contains('connection refused')) {
        return NetworkErrorType.connectionRefused;
      }
      if (msg.contains('network is unreachable') || msg.contains('no route to host')) {
        return NetworkErrorType.networkUnreachable;
      }
    }
    if (inner is HandshakeException || (inner != null && inner.toString().contains('CERTIFICATE_VERIFY_FAILED'))) {
      return NetworkErrorType.tlsError;
    }
    final str = inner?.toString().toLowerCase() ?? '';
    if (str.contains('failed host lookup')) return NetworkErrorType.dnsFailure;
    if (str.contains('connection refused')) return NetworkErrorType.connectionRefused;
    if (str.contains('handshake') || str.contains('certificate')) return NetworkErrorType.tlsError;
    if (str.contains('network is unreachable')) return NetworkErrorType.networkUnreachable;

    return NetworkErrorType.connectionError;
  }

  /// Returns true if the error is a network-level issue (useful for showing diagnose button).
  static bool isNetworkError(dynamic e) {
    final type = classifyError(e);
    return const {
      NetworkErrorType.timeout,
      NetworkErrorType.dnsFailure,
      NetworkErrorType.connectionRefused,
      NetworkErrorType.tlsError,
      NetworkErrorType.networkUnreachable,
      NetworkErrorType.connectionError,
    }.contains(type);
  }

  /// Returns true if the error message represents a network-level failure.
  static bool isNetworkErrorMessage(String message) {
    final lower = message.toLowerCase();
    return lower.contains('timed out') ||
        lower.contains('dns') ||
        lower.contains('unable to connect') ||
        lower.contains('network') ||
        lower.contains('tls') ||
        lower.contains('ssl') ||
        lower.contains('unreachable') ||
        lower.contains('انتهت مهلة') ||
        lower.contains('تعذر الاتصال') ||
        lower.contains('الشبكة');
  }

  /// Maps a Dio error to a user-friendly localized message.
  /// Pass [l10n] to get a localized string; falls back to English if null.
  static String mapDioErrorToMessage(dynamic e, [AppLocalizations? l10n]) {
    if (e is DioException) {
      final errorType = classifyError(e);

      switch (errorType) {
        case NetworkErrorType.timeout:
          return l10n?.errorConnectionTimeout ??
              "Connection timed out.\n\nThe server may be busy or unreachable. Please try again in a moment.";

        case NetworkErrorType.dnsFailure:
          return l10n?.errorDnsFailure ??
              "DNS resolution failed.\n\nYour network may be blocking this domain. Try switching to a different network.";

        case NetworkErrorType.connectionRefused:
          return l10n?.errorConnectionRefused ??
              "Connection refused.\n\nThe server is not accepting connections. Please try again later.";

        case NetworkErrorType.tlsError:
          return l10n?.errorTlsFailure ??
              "Secure connection failed.\n\nYour network may be intercepting traffic. Try a different network.";

        case NetworkErrorType.networkUnreachable:
          return l10n?.errorNetworkUnreachable ??
              "Network is unreachable.\n\nPlease check your internet connection.";

        case NetworkErrorType.connectionError:
          return l10n?.errorConnectionFailed ??
              "Unable to connect to the server.\n\nPlease check your internet connection and try again.";

        case NetworkErrorType.auth:
          return l10n?.errorAuthFailed ??
              "Authentication failed.\n\nYour session may have expired. Please log in again.";

        case NetworkErrorType.permission:
          final message =
              e.response?.data is Map ? e.response?.data['message'] : null;
          if (message != null &&
              message.toString().toLowerCase().contains('subscription')) {
            return "[SUBSCRIPTION_REQUIRED]$message";
          }
          return l10n?.errorPermissionDenied ??
              "Permission denied.\n\nYou do not have access to this resource.";

        case NetworkErrorType.notFound:
          return l10n?.errorNotFound ??
              "Resource not found.\n\nThe requested data could not be located.";

        case NetworkErrorType.serverError:
          final statusCode = e.response?.statusCode;
          return e.response?.data['message'] ??
              l10n?.errorServerGeneric(statusCode ?? 500) ??
              "Server error ($statusCode).\n\nPlease try again later.";

        case NetworkErrorType.cancelled:
          return l10n?.errorRequestCancelled ?? "Request cancelled.";

        case NetworkErrorType.unknown:
          return l10n?.errorNetwork ??
              "Network error.\n\nPlease check your internet connection and try again.";
      }
    }
    return l10n?.errorUnexpected ?? "An unexpected error occurred: $e";
  }
}
