import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:velvors/config/env_config.dart';

class ServiceHelp {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  static Future<List<Map<String, dynamic>>> fetchFaqs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/support/faqs/get'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Fetch FAQs Status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching FAQs: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> requestCallback({
    required String callbackDate,
    required String timeWindow,
    required String topic,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/user/support/callback'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "callbackDate": callbackDate,
          "timeWindow": timeWindow,
          "topic": topic,
        }),
      );

      debugPrint('Request Callback Status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        return {'success': true, 'data': decoded};
      }
      return {'success': false, 'error': 'Server error: ${response.statusCode}'};
    } catch (e) {
      debugPrint('Error requesting callback: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<List<Map<String, dynamic>>> fetchCallbackHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/user/support/callback/history'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Fetch Callback History Status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching callback history: $e');
      return [];
    }
  }
}
