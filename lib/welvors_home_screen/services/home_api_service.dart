import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:velvors/config/env_config.dart';

import 'logger_service.dart';

class HomeApiService {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  static Future<Map<String, dynamic>?> fetchFeed({
    int limit = 10,
    String? cursor,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      String urlStr = '$baseUrl/user/feed?limit=$limit';
      if (cursor != null && cursor.isNotEmpty) {
        urlStr += '&cursor=$cursor';
      }

      final url = Uri.parse(urlStr);
      final request = http.Request('GET', url);

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      if (filters != null && filters.isNotEmpty) {
        request.body = jsonEncode({'filters': filters});
      }

      AppLogger.apiRequest(
        'HomeApiService',
        method: 'GET',
        url: urlStr,
        headers: request.headers,
        body: request.body.isNotEmpty ? request.body : null,
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.apiResponse(
        'HomeApiService',
        statusCode: response.statusCode,
        body: response.body,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          return decoded;
        }
      } else {
        AppLogger.e(
          'HomeApiService',
          'Feed API failed with status ${response.statusCode}: ${response.body}',
        );
      }
      return null;
    } catch (e, st) {
      AppLogger.e('HomeApiService', 'Error fetching feed: $e', error: e, stackTrace: st);
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = Uri.parse('$baseUrl/user/feed/details/$userId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return decoded['data'];
        }
      }
      return null;
    } catch (e, st) {
      AppLogger.e('HomeApiService', 'Error fetching user details: $e', error: e, stackTrace: st);
      return null;
    }
  }
}
