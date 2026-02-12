class AppConstants {
  // API Configuration
  // For Android Emulator use: 10.0.2.2
  // For iOS Simulator use: localhost
  // For Physical Device use: Your PC's IP address (e.g., 192.168.1.x)
  // For Android Emulator: http://10.0.2.2:3000
  // For Physical Device: Use your PC's local IP address
  static const String apiBaseUrl = 'http://192.168.1.227:3001';
  static const String apiVersion = 'v1';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  
  // Token refresh
  static const String refreshEndpoint = '/auth/refresh';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // App Info
  static const String appName = 'MikroTik Hotspot Manager';
  static const String appVersion = '1.0.0';
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayDateTimeFormat = 'MMM dd, yyyy HH:mm';
}
