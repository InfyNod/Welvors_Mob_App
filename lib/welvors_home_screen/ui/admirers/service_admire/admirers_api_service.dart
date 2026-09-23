import 'dart:convert';
import '../../../services/logger_service.dart';
import '../../../services/token_helper.dart';
import 'package:http/http.dart' as http;

import 'package:velvors/config/env_config.dart';

class AdmirersApiService {
  static String get baseUrl => '${EnvConfig.apiBaseUrl}/user/admirers';

  static Future<Map<String, String>> _getHeaders() async {
    final token = await TokenHelper.getToken();
    final authHeader = token != null && token.toLowerCase().startsWith('bearer ')
        ? token
        : 'Bearer $token';
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': authHeader,
    };
  }

  /// Fetches Received Likes
  Future<Map<String, dynamic>> getReceivedLikes({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl?type=LIKE&direction=RECEIVED&page=$page&limit=$limit');
    
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        AppLogger.e('AdmirersApiService', 'Failed to load received admirers: ${response.statusCode} ${response.body}');
        return {'success': false, 'data': []};
      }
    } catch (e) {
      AppLogger.e('AdmirersApiService', 'Error fetching received admirers: $e');
      return {'success': false, 'data': []};
    }
  }

  /// Fetches Sent Likes
  Future<Map<String, dynamic>> getSentLikes({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl?type=LIKE&direction=SENT&page=$page&limit=$limit');
    
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        AppLogger.e('AdmirersApiService', 'Failed to load sent admirers: ${response.statusCode} ${response.body}');
        return {'success': false, 'data': []};
      }
    } catch (e) {
      AppLogger.e('AdmirersApiService', 'Error fetching sent admirers: $e');
      return {'success': false, 'data': []};
    }
  }

  /// Fetches Received Roses
  Future<Map<String, dynamic>> getReceivedRoses({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl?type=ROSE&direction=RECEIVED&page=$page&limit=$limit');
    
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        AppLogger.e('AdmirersApiService', 'Failed to load received roses: ${response.statusCode} ${response.body}');
        return {'success': false, 'data': []};
      }
    } catch (e) {
      AppLogger.e('AdmirersApiService', 'Error fetching received roses: $e');
      return {'success': false, 'data': []};
    }
  }

  /// Fetches Sent Roses
  Future<Map<String, dynamic>> getSentRoses({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl?type=ROSE&direction=SENT&page=$page&limit=$limit');
    
    try {
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        AppLogger.e('AdmirersApiService', 'Failed to load sent roses: ${response.statusCode} ${response.body}');
        return {'success': false, 'data': []};
      }
    } catch (e) {
      AppLogger.e('AdmirersApiService', 'Error fetching sent roses: $e');
      return {'success': false, 'data': []};
    }
  }

  /// Swipes on a user (LIKE or PASS)
  Future<Map<String, dynamic>> swipeUser({required String targetUserId, required String action}) async {
    final url = Uri.parse('${EnvConfig.apiBaseUrl}/user/swipe');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await TokenHelper.getToken() ?? ""}',
        },
        body: json.encode({
          'targetUserId': targetUserId,
          'action': action,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to swipe. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error swiping: $e');
    }
  }

  /// Sends a Rose to a user
  Future<Map<String, dynamic>> sendRose({required String receiverId}) async {
    final url = Uri.parse('${EnvConfig.apiBaseUrl}/user/rose/send');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await TokenHelper.getToken() ?? ""}',
        },
        body: json.encode({
          'receiverId': receiverId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        AppLogger.e(
          'AdmirersApiService',
          'Failed to send rose. Status: ${response.statusCode}, Body: ${response.body}',
        );
        throw Exception('Failed to send rose. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending rose: $e');
    }
  }
}
