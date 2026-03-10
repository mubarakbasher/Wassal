import 'package:dio/dio.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';

class ErrorHandler {
  /// Maps a Dio error to a user-friendly localized message.
  /// Pass [l10n] to get a localized string; falls back to English if null.
  static String mapDioErrorToMessage(dynamic e, [AppLocalizations? l10n]) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return l10n?.errorConnectionTimeout ??
              "Connection timed out.\n\nThe server may be busy or unreachable. Please try again in a moment.";

        case DioExceptionType.connectionError:
          return l10n?.errorConnectionFailed ??
              "Unable to connect to the server.\n\nPlease check your internet connection and try again.";

        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 401) {
            return l10n?.errorAuthFailed ??
                "Authentication failed.\n\nYour session may have expired. Please log in again.";
          } else if (statusCode == 403) {
            final message =
                e.response?.data is Map ? e.response?.data['message'] : null;
            if (message != null &&
                message.toString().toLowerCase().contains('subscription')) {
              return "[SUBSCRIPTION_REQUIRED]$message";
            }
            return l10n?.errorPermissionDenied ??
                "Permission denied.\n\nYou do not have access to this resource.";
          } else if (statusCode == 404) {
            return l10n?.errorNotFound ??
                "Resource not found.\n\nThe requested data could not be located.";
          }
          return e.response?.data['message'] ??
              l10n?.errorServerGeneric(statusCode ?? 500) ??
              "Server error ($statusCode).\n\nPlease try again later.";

        case DioExceptionType.cancel:
          return l10n?.errorRequestCancelled ?? "Request cancelled.";

        default:
          return l10n?.errorNetwork ??
              "Network error.\n\nPlease check your internet connection and try again.";
      }
    }
    return l10n?.errorUnexpected ?? "An unexpected error occurred: $e";
  }
}
