import 'package:dio/dio.dart';

class ErrorHandler {
  static String mapDioErrorToMessage(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Connection Timeout. \n\nPossible Solution: Check if the IP address is correct and the router is reachable from this network.";
        
        case DioExceptionType.connectionError:
           return "Connection Error. \n\nPossible Solution: Ensure the router is powered on and the API service is enabled.";

        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 401) {
             return "Authentication Failed. \n\nPossible Solution: Check your username and password.";
          } else if (statusCode == 403) {
             final message = e.response?.data is Map ? e.response?.data['message'] : null;
             if (message != null && message.toString().toLowerCase().contains('subscription')) {
               return "[SUBSCRIPTION_REQUIRED]$message";
             }
             return "Permission Denied. \n\nPossible Solution: The user does not have sufficient rights.";
          } else if (statusCode == 404) {
             return "Resource Not Found. \n\nPossible Solution: The requested resource path is incorrect.";
          }
           return e.response?.data['message'] ?? "Server Error ($statusCode). \n\nPossible Solution: Check server logs.";

        case DioExceptionType.cancel:
          return "Request Cancelled.";
          
        default:
          return "Network Error: ${e.message}. \n\nPossible Solution: Check your internet connection.";
      }
    }
    return "An unexpected error occurred: $e";
  }
}
