import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:velvors/config/env_config.dart';

import '../../../../services/logger_service.dart';

class NotificationRepository {
  static String get baseUrl => EnvConfig.baseUrl;

  /// ============================================================
  /// GET NOTIFICATIONS
  /// ============================================================
  Future<Map<String, dynamic>> fetchNotifications({
    String category = 'ALL',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final uri = Uri.parse('$baseUrl/api/user/notification?category=$category');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': token!.startsWith('Bearer ') ? token : 'Bearer $token',
      },
    );

    AppLogger.apiResponse(
      'NotificationRepository',
      statusCode: response.statusCode,
      body: response.body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception('Notification API failed: ${response.statusCode}');
  }

  /// ============================================================
  /// MARK SINGLE NOTIFICATION AS READ
  /// ============================================================

  Future<void> markNotificationAsRead(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    /*
      IMPORTANT:

      Agar backend ka mark-read endpoint different hai,
      sirf ye URL change karein.

      Current assumed endpoint:
      PATCH /api/notifications/{notificationId}/read
    */

    final uri = Uri.parse('$baseUrl/api/notification/$notificationId/read');

    AppLogger.apiRequest(
      'NotificationRepository',
      method: 'PATCH',
      url: uri.toString(),
    );

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    AppLogger.apiResponse(
      'NotificationRepository',
      statusCode: response.statusCode,
      body: response.body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception('Unable to mark notification as read');
  }

  /// ============================================================
  /// MARK ALL AS READ
  /// ============================================================

  Future<void> markAllNotificationsAsRead() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    /*
      Assumed endpoint:
      PATCH /api/notifications/read-all
    */

    final uri = Uri.parse('$baseUrl/api/user/notification/read-all');
    AppLogger.apiRequest(
      'NotificationRepository',
      method: 'PATCH',
      url: uri.toString(),
    );

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    AppLogger.apiResponse(
      'NotificationRepository',
      statusCode: response.statusCode,
      body: response.body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception('Unable to mark all notifications as read');
  }

  /// ============================================================
  /// GET UNREAD NOTIFICATION COUNT
  /// ============================================================

  Future<int> getUnreadNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final uri = Uri.parse('$baseUrl/api/user/notification/unread-count');

    AppLogger.apiRequest(
      'NotificationRepository',
      method: 'GET',
      url: uri.toString(),
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
      },
    );

    AppLogger.apiResponse(
      'NotificationRepository',
      statusCode: response.statusCode,
      body: response.body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      final data = decoded['data'];

      if (data is Map<String, dynamic>) {
        final unreadCount = data['unreadCount'];

        if (unreadCount is int) {
          return unreadCount;
        }

        if (unreadCount is String) {
          return int.tryParse(unreadCount) ?? 0;
        }
      }

      // Fallback agar API direct unreadCount return kare
      final unreadCount = decoded['unreadCount'];

      if (unreadCount is int) {
        return unreadCount;
      }

      if (unreadCount is String) {
        return int.tryParse(unreadCount) ?? 0;
      }

      return 0;
    }

    throw Exception(
      'Unable to get unread notification count: ${response.statusCode}',
    );
  }
}
