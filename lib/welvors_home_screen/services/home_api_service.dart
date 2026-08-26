import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeApiService {
  static const String baseUrl = 'https://api.welvors.com/api';

  static Future<Map<String, dynamic>?> fetchFeed({
    int limit = 10,
    String? cursor,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final token =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs';
      String urlStr = '$baseUrl/user/feed?limit=$limit';
      if (cursor != null && cursor.isNotEmpty) {
        urlStr += '&cursor=$cursor';
      }

      final url = Uri.parse(urlStr);
      final request = http.Request('GET', url);
      
      request.headers.addAll({
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      if (filters != null && filters.isNotEmpty) {
        request.body = jsonEncode({'filters': filters});
      }

      print('====== [API SERVICE] SENDING GET REQUEST ======');
      print('URL: $urlStr');
      print('HEADERS: ${request.headers}');
      print('BODY: ${request.body}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('====== [API SERVICE] RESPONSE RECEIVED ======');
      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          return decoded;
        }
      } else {
        debugPrint('Feed API failed with status ${response.statusCode}: ${response.body}');
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching feed: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
    try {
      final token =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs';

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
