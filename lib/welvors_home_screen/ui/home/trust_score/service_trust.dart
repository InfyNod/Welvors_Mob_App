import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvors/config/env_config.dart';

class ServiceTrust {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  static Future<Map<String, dynamic>?> fetchTrustScore(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = Uri.parse('$baseUrl/user/profile/$userId/trust-score');
      
      if (kDebugMode) {
        print('Fetching trust score from: $url');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print('Trust Score API Response Status: ${response.statusCode}');
        print('Trust Score API Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded;
      }
      return null;
    } catch (e, st) {
      if (kDebugMode) {
        print('Error fetching trust score: $e');
        print(st);
      }
      return null;
    }
  }
}
