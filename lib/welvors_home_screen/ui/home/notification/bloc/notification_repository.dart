import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepository {
  static const String baseUrl = 'https://api.welvors.com';

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

    print('🔔 Notification URL: $uri');
    print('🔔 Notification Status: ${response.statusCode}');
    print('🔔 Notification Response: ${response.body}');

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

    print('🔔 MARK READ');
    print('PATCH: $uri');

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('🔔 Mark read status: ${response.statusCode}');
    print('🔔 Mark read response: ${response.body}');

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
    print('🔔 MARK ALL READ');
    print('PATCH: $uri');

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('🔔 Mark all status: ${response.statusCode}');
    print('🔔 Mark all response: ${response.body}');

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

    print('🔔 GET UNREAD NOTIFICATION COUNT');
    print('GET: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
      },
    );

    print('🔔 Unread count status: ${response.statusCode}');
    print('🔔 Unread count response: ${response.body}');

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
