import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/app_constants.dart';

/// Result from server health check
class ServerHealthResult {
  final bool isHealthy;
  final bool isMaintenance;
  final String? message;

  const ServerHealthResult({
    required this.isHealthy,
    this.isMaintenance = false,
    this.message,
  });
}

/// Service to perform startup checks
class StartupService {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;
  final Connectivity connectivity;

  StartupService({
    required this.apiClient,
    required this.secureStorage,
    Connectivity? connectivity,
  }) : connectivity = connectivity ?? Connectivity();

  /// Check if device has internet connectivity
  Future<bool> checkInternetConnection() async {
    try {
      final results = await connectivity.checkConnectivity();
      // connectivity_plus 6.x returns a List<ConnectivityResult>
      return results.isNotEmpty && !results.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  /// Ping backend health endpoint
  Future<ServerHealthResult> pingServerHealth() async {
    try {
      final response = await apiClient.get('/health');
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Check if server is in maintenance mode
        if (data is Map && data['maintenance'] == true) {
          return ServerHealthResult(
            isHealthy: false,
            isMaintenance: true,
            message: data['message'] ?? 'App is under maintenance',
          );
        }
        
        return const ServerHealthResult(isHealthy: true);
      }
      
      return const ServerHealthResult(
        isHealthy: false,
        message: 'Server returned error',
      );
    } catch (e) {
      // Provide user-friendly error messages
      String userMessage = 'Unable to reach our servers. Please check your connection and try again.';
      
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('timeout')) {
        userMessage = 'The server is taking too long to respond. Please try again in a moment.';
      } else if (errorString.contains('connection refused') || errorString.contains('failed host lookup')) {
        userMessage = 'Cannot connect to the server. Please check your internet connection.';
      } else if (errorString.contains('socket')) {
        userMessage = 'Network connection lost. Please check your internet and try again.';
      }
      
      return ServerHealthResult(
        isHealthy: false,
        message: userMessage,
      );
    }
  }

  /// Validate if user session/token is still valid
  Future<bool> validateSession() async {
    try {
      final token = await secureStorage.read(key: AppConstants.accessTokenKey);
      
      if (token == null || token.isEmpty) {
        return false;
      }

      // Try to fetch profile to validate token
      final response = await apiClient.get('/auth/profile');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Load app configuration and feature flags
  Future<void> loadAppConfiguration() async {
    try {
      // In a real app, this would fetch feature flags, remote config, etc.
      // For now, we simulate a brief loading time
      await Future.delayed(const Duration(milliseconds: 200));
      
      // You could add actual config loading here:
      // final response = await apiClient.get('/config');
      // AppConfig.instance.update(response.data);
    } catch (e) {
      // Configuration loading is non-critical, continue anyway
    }
  }
}
