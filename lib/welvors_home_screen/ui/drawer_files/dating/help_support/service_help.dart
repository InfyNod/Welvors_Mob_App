import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ServiceHelp {
  static const String baseUrl = 'https://api.welvors.com/api';

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
}
