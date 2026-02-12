import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/api/api_client.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
}

/// Service to handle push notifications for router status updates
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  
  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  ApiClient? _apiClient;
  Function(String routerId, bool isOnline)? onRouterStatusChanged;
  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize(ApiClient apiClient) async {
    if (_initialized) return;
    _apiClient = apiClient;

    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      
      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request notification permissions
      await _requestPermissions();

      // Initialize local notifications for foreground display
      await _initializeLocalNotifications();

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background but not terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification when terminated
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _initialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize NotificationService: $e');
    }
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Notification permission status: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap
        _handleLocalNotificationTap(response.payload);
      },
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'router_status',
        'Router Status',
        description: 'Notifications when routers go online or offline',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.messageId}');
    
    final notification = message.notification;
    if (notification != null) {
      // Show local notification when app is in foreground
      _showLocalNotification(
        title: notification.title ?? 'Router Status',
        body: notification.body ?? '',
        payload: message.data['routerId'],
      );
    }

    // Handle router status update
    final data = message.data;
    if (data['type'] == 'router_status') {
      final routerId = data['routerId'];
      final isOnline = data['status'] == 'online';
      onRouterStatusChanged?.call(routerId, isOnline);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.messageId}');
    
    final data = message.data;
    if (data['type'] == 'router_status') {
      final routerId = data['routerId'];
      // Navigate to router details - implement in app
      debugPrint('Navigate to router: $routerId');
    }
  }

  void _handleLocalNotificationTap(String? payload) {
    if (payload != null) {
      debugPrint('Local notification tapped, routerId: $payload');
      // Navigate to router details - implement in app
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'router_status',
      'Router Status',
      channelDescription: 'Notifications when routers go online or offline',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Register device token with backend
  Future<void> registerDeviceToken() async {
    if (_apiClient == null) {
      debugPrint('API client not set, cannot register token');
      return;
    }

    try {
      final token = await _messaging.getToken();
      if (token == null) {
        debugPrint('Failed to get FCM token');
        return;
      }

      final platform = Platform.isAndroid ? 'android' : 'ios';
      
      await _apiClient!.post('/notifications/register-token', data: {
        'token': token,
        'platform': platform,
      });

      debugPrint('Device token registered successfully');

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _registerToken(newToken, platform);
      });
    } catch (e) {
      debugPrint('Failed to register device token: $e');
    }
  }

  Future<void> _registerToken(String token, String platform) async {
    try {
      await _apiClient?.post('/notifications/register-token', data: {
        'token': token,
        'platform': platform,
      });
      debugPrint('Token refreshed and re-registered');
    } catch (e) {
      debugPrint('Failed to re-register token: $e');
    }
  }

  /// Unregister device token (on logout)
  Future<void> unregisterDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _apiClient?.delete('/notifications/remove-token', data: {
          'token': token,
        });
        debugPrint('Device token unregistered');
      }
    } catch (e) {
      debugPrint('Failed to unregister device token: $e');
    }
  }
}
