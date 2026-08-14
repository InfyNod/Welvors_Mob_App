import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeApiService {
  static const String baseUrl = 'https://dating-app-backend-plum.vercel.app/api';

  static Future<Map<String, dynamic>?> fetchFeed({int limit = 10, String? cursor}) async {
    try {
      final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY0MjczNTAsImV4cCI6MTc4NzAzMjE1MH0.GUeaaa-GUmgs2elvACLaxuYnKhSnM0zv4k2sp0GR5dU';
      String urlStr = '$baseUrl/user/feed?limit=$limit';
      if (cursor != null && cursor.isNotEmpty) {
        urlStr += '&cursor=$cursor';
      }

      final url = Uri.parse(urlStr);
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          return decoded;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching feed: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
    try {
      final token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY0MjczNTAsImV4cCI6MTc4NzAzMjE1MH0.GUeaaa-GUmgs2elvACLaxuYnKhSnM0zv4k2sp0GR5dU';

      final url = Uri.parse('$baseUrl/user/feed/details/$userId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
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
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      return null;
    }
  }
}
