import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class DateNowApiService {
  static const String baseUrl = 'https://api.welvors.com/api';
  
  // Hardcoded token for now as per home_api_service.dart pattern
  static const String _token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  // Example structure for API methods. You can provide the endpoints and I'll fill them in!
  
  // POST Request Example
  static Future<Map<String, dynamic>?> postPlan(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plans');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to post plan: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error posting plan: $e');
      return null;
    }
  }

  // Generic GET Options (for ACTIVITY, QUICK_TITLE, VIBE)
  static Future<List<dynamic>?> getOptions(String type) async {
    try {
      final url = Uri.parse('$baseUrl/admin/date-now/options?type=$type');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          return decoded['data'] as List<dynamic>;
        }
      } else {
        debugPrint('Failed to get $type: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching $type: $e');
      return null;
    }
  }

  // PATCH Request Example
  static Future<Map<String, dynamic>?> updatePlan(String planId, Map<String, dynamic> data) async {
    // To be implemented when API is provided
    return null;
  }
}
