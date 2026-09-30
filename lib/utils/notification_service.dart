// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvors/main.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';
import 'package:velvors/welvors_home_screen/ui/home/notification/services/notification_api_service.dart';

class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();

  // Factory constructor to return the same instance
  factory NotificationService() {
    return _instance;
  }

  // Private constructor
  NotificationService._internal();

  // Flag to track if service is initialized
  bool _isInitialized = false;

  // Firebase messaging plugin
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Flutter local notifications plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Android Notification Channel
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
  );

  // Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the notification service once at app startup
  Future<void> initialize([BuildContext? context]) async {
    if (_isInitialized) {
      AppLogger.d('NotificationService', 'NotificationService already initialized, skipping');
      return;
    }

    try {
      // 1. Request notification permissions
      await requestNotificationPermission();

      // 2. Initialize local notifications plugin and notification channel
      await _initLocalNotifications();

      // 3. Listen for token refreshes
      setupTokenRefresh();

      // 4. Setup foreground and background notification message handlers
      firebaseInit();
      setupInteractMessage();

      // 5. Retrieve device token and sync to server if already logged in
      final token = await getDeviceToken();
      if (token != null && token.isNotEmpty) {
        await sendDeviceTokenToServer(token);
      }

      _isInitialized = true;
      AppLogger.d('NotificationService', 'NotificationService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.e('NotificationService', 'Failed to initialize NotificationService: $e');
      debugPrint(stackTrace.toString());
    }
  }

  /// Request notification permission for Android and iOS
  Future<NotificationSettings> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.d('NotificationService', 'User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      AppLogger.d('NotificationService', 'User granted provisional notification permission');
    } else {
      AppLogger.w('NotificationService', 'User denied notification permission');
    }

    return settings;
  }

  /// Fetch FCM Device Token and cache it in SharedPreferences
  Future<String?> getDeviceToken() async {
    try {
      String? token = await messaging.getToken();
      if (token != null && token.isNotEmpty) {
        AppLogger.d('NotificationService', 'FCM Token => $token');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        return token;
      } else {
        AppLogger.w('NotificationService', 'FCM Token returned null');
      }
    } catch (e) {
      AppLogger.e('NotificationService', 'Error getting FCM Token: $e');
    }
    return null;
  }

  /// Listen for FCM token refresh and automatically sync with backend
  void setupTokenRefresh() {
    messaging.onTokenRefresh.listen((String newToken) async {
      AppLogger.d('NotificationService', 'FCM Token Refreshed => $newToken');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', newToken);
      await sendDeviceTokenToServer(newToken);
    });
  }

  /// Sends FCM device token to backend API:
  /// POST https://api.welvors.com/api/user/notifications/device-token
  /// Body: {"deviceToken": "<fcm_token>"}
  Future<bool> sendDeviceTokenToServer([String? token]) async {
    try {
      String? deviceToken = token;
      if (deviceToken == null || deviceToken.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        deviceToken = prefs.getString('fcm_token');
      }

      if (deviceToken == null || deviceToken.isEmpty) {
        deviceToken = await getDeviceToken();
      }

      if (deviceToken == null || deviceToken.isEmpty) {
        AppLogger.w('NotificationService', 'No FCM device token available to send');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token')?.trim() ?? '';
      if (authToken.isEmpty) {
        AppLogger.d(
          'NotificationService',
          'User not logged in yet (no auth_token). Device token will be sent after login/verification.',
        );
        return false;
      }

      final success = await NotificationApiService.saveDeviceToken(deviceToken);
      if (success) {
        AppLogger.d('NotificationService', 'Device token successfully saved to server');
      } else {
        AppLogger.w('NotificationService', 'Failed to save device token to server');
      }
      return success;
    } catch (e) {
      AppLogger.e('NotificationService', 'Error in sendDeviceTokenToServer: $e');
      return false;
    }
  }

  /// Initialise Flutter Local Notifications plugin (called once)
  Future<void> _initLocalNotifications() async {
    const androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSetting = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    // Create High Importance notification channel on Android
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSetting,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleLocalNotificationResponse(response);
      },
    );
  }

  /// Initialise foreground message handling
  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.d('NotificationService', 'Foreground message: ${message.messageId}');
      AppLogger.d('NotificationService', 'Data: ${message.data}');

      if (Platform.isIOS) {
        foregroundMessage();
      }

      if (Platform.isAndroid) {
        showNotification(message);
      }
    });
  }

  /// Handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage() async {
    // When app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage event) {
      handleMessage(event);
    });

    // Handle terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        handleMessage(message);
      }
    });
  }

  /// Show visible local notification when app is active
  Future<void> showNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final title = notification?.title ?? message.data['title']?.toString() ?? 'Notification';
      final body = notification?.body ?? message.data['body']?.toString() ?? '';

      final androidNotificationDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: darwinNotificationDetails,
      );

      final int notificationId = message.hashCode;

      await _flutterLocalNotificationsPlugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: jsonEncode(message.data),
      );
    } catch (e) {
      AppLogger.e('NotificationService', 'Error showing notification: $e');
    }
  }

  /// Presentation options for foreground notifications on iOS
  Future<void> foregroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Alias for backward compatibility
  Future<void> forgroundMessage() => foregroundMessage();

  /// Handle tap on local notification
  void _handleLocalNotificationResponse(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        _navigateToDestination(data);
      } catch (e) {
        AppLogger.e('NotificationService', 'Error parsing local notification payload: $e');
      }
    }
  }

  /// Handle RemoteMessage click
  Future<void> handleMessage(RemoteMessage message) async {
    AppLogger.d('NotificationService', 'Handling notification message: ${message.data}');
    _navigateToDestination(message.data);
  }

  /// Centralized notification destination router
  void _navigateToDestination(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      AppLogger.w('NotificationService', 'Navigation context is null');
      return;
    }

    final type = data['type']?.toString().toUpperCase();
    AppLogger.d('NotificationService', 'Navigating for notification type: $type');

    // Handle deep linking or route navigation based on notification data
    if (type == 'CHAT') {
      // Future navigation: push chat screen
    } else if (type == 'NOTIFICATION') {
      // Navigator.pushNamed(context, '/notifications');
    }
  }
}
