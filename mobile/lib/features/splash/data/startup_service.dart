import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/app_constants.dart';

/// Result from server health check
class ServerHealthResult {
  final bool isHealthy;
  final bool isMaintenance;
  final String? message;
  final bool isDnsFailure;

  const ServerHealthResult({
    required this.isHealthy,
    this.isMaintenance = false,
    this.message,
    this.isDnsFailure = false,
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
      return results.isNotEmpty && !results.contains(ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  /// Perform a real DNS lookup to verify the API host is resolvable.
  /// Returns the resolved addresses or null on failure.
  Future<List<InternetAddress>?> checkDnsResolution(String hostname) async {
    try {
      final addresses = await InternetAddress.lookup(hostname)
          .timeout(const Duration(seconds: 10));
      return addresses.isNotEmpty ? addresses : null;
    } catch (_) {
      return null;
    }
  }

  /// Ping backend health endpoint with enriched error diagnostics
  Future<ServerHealthResult> pingServerHealth() async {
    try {
      final response = await apiClient.get('/health');
      
      if (response.statusCode == 200) {
        final data = response.data;
        
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
      String userMessage = 'Unable to reach our servers. Please check your connection and try again.';
      bool isDns = false;
      
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('failed host lookup') || errorString.contains('no address associated')) {
        isDns = true;
        // Confirm whether it's a DNS-specific issue or no internet at all
        final googleDns = await checkDnsResolution('google.com');
        if (googleDns != null) {
          userMessage = 'DNS resolution failed for our server. Your network may be blocking this domain. Try switching networks.';
        } else {
          userMessage = 'Cannot resolve any domain. Please check your internet connection.';
        }
      } else if (errorString.contains('timeout')) {
        userMessage = 'The server is taking too long to respond. Please try again in a moment.';
      } else if (errorString.contains('connection refused')) {
        userMessage = 'Cannot connect to the server. The server may be temporarily down.';
      } else if (errorString.contains('handshake') || errorString.contains('certificate')) {
        userMessage = 'Secure connection failed. Your network may be intercepting traffic. Try a different network.';
      } else if (errorString.contains('socket') || errorString.contains('network is unreachable')) {
        userMessage = 'Network connection lost. Please check your internet and try again.';
      }
      
      return ServerHealthResult(
        isHealthy: false,
        message: userMessage,
        isDnsFailure: isDns,
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

      final response = await apiClient.get('/auth/profile');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Load app configuration and feature flags
  Future<void> loadAppConfiguration() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      // Configuration loading is non-critical, continue anyway
    }
  }
}
