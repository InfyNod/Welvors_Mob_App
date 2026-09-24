import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvors/main.dart';

import '../../../../services/logger_service.dart';
import '../model/notification_model.dart';

import 'package:velvors/config/env_config.dart';

class NotificationApiService {
  static String get _baseUrl => '${EnvConfig.apiBaseUrl}/user/notification';

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token')?.trim() ?? '';

    if (token.isEmpty) {
      throw Exception('Authentication token is missing');
    }

    final authorization = token.toLowerCase().startsWith('bearer ')
        ? token
        : 'Bearer $token';

    return <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': authorization,
    };
  }

  static Future<void> _handleAuth(int statusCode) async {
    if (statusCode != 401 && statusCode != 403) return;

    AppLogger.w(
      'NotificationApiService',
      '🔐 Notification API token expired ($statusCode)',
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    if (navigatorKey.currentContext != null) {
      Navigator.pushNamedAndRemoveUntil(
        navigatorKey.currentContext!,
        '/landing',
        (route) => false,
      );
    }
  }

  static Future<List<NotificationModel>> getNotifications({
    String category = 'ALL',
  }) async {
    final normalizedCategory = category.trim().isEmpty ? 'ALL' : category;

    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: <String, String>{'category': normalizedCategory},
    );

    AppLogger.d('NotificationApiService', '🔔 GET NOTIFICATIONS');
    AppLogger.d('NotificationApiService', 'URL: $uri');

    final response = await http.get(uri, headers: await _headers());

    AppLogger.d('NotificationApiService', 'NOTIFICATION STATUS: ${response.statusCode}');
    AppLogger.d('NotificationApiService', 'NOTIFICATION BODY: ${response.body}');

    await _handleAuth(response.statusCode);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _messageFromResponse(
          response.body,
          'Unable to fetch notifications (${response.statusCode})',
        ),
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw Exception('Invalid notification response');
    }

    final data = decoded['data'];
    final notifications = data is Map ? data['notifications'] : null;

    if (notifications is! List) {
      return <NotificationModel>[];
    }

    return notifications
        .whereType<Map>()
        .map(
          (item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static Future<int> getUnreadCount() async {
    final uri = Uri.parse('$_baseUrl/unread-count');

    AppLogger.d('NotificationApiService', '🔔 GET UNREAD COUNT');
    AppLogger.d('NotificationApiService', 'URL: $uri');

    final response = await http.get(uri, headers: await _headers());

    AppLogger.d('NotificationApiService', 'UNREAD COUNT STATUS: ${response.statusCode}');
    AppLogger.d('NotificationApiService', 'UNREAD COUNT BODY: ${response.body}');

    await _handleAuth(response.statusCode);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _messageFromResponse(
          response.body,
          'Unable to fetch unread count (${response.statusCode})',
        ),
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) return 0;

    final data = decoded['data'];
    if (data is Map) {
      final value = data['unreadCount'] ?? data['count'];
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final direct = decoded['unreadCount'] ?? decoded['count'];
    return int.tryParse(direct?.toString() ?? '') ?? 0;
  }

  static Future<void> markAsRead(String notificationId) async {
    final id = notificationId.trim();
    if (id.isEmpty) throw Exception('Notification id is empty');

    final uri = Uri.parse('$_baseUrl/$id/read');

    AppLogger.d('NotificationApiService', '🔔 PATCH NOTIFICATION READ');
    AppLogger.d('NotificationApiService', 'URL: $uri');

    final response = await http.patch(uri, headers: await _headers());

    AppLogger.d('NotificationApiService', 'MARK READ STATUS: ${response.statusCode}');
    AppLogger.d('NotificationApiService', 'MARK READ BODY: ${response.body}');

    await _handleAuth(response.statusCode);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _messageFromResponse(
          response.body,
          'Unable to mark notification as read (${response.statusCode})',
        ),
      );
    }
  }

  static Future<void> markAllAsRead() async {
    final uri = Uri.parse('$_baseUrl/read-all');

    AppLogger.d('NotificationApiService', '🔔 PATCH ALL NOTIFICATIONS READ');
    AppLogger.d('NotificationApiService', 'URL: $uri');

    final response = await http.patch(uri, headers: await _headers());

    AppLogger.d('NotificationApiService', 'MARK ALL READ STATUS: ${response.statusCode}');
    AppLogger.d('NotificationApiService', 'MARK ALL READ BODY: ${response.body}');

    await _handleAuth(response.statusCode);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _messageFromResponse(
          response.body,
          'Unable to mark all notifications as read (${response.statusCode})',
        ),
      );
    }
  }

  static String _messageFromResponse(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {}

    return body.trim().isNotEmpty ? body.trim() : fallback;
  }
}
