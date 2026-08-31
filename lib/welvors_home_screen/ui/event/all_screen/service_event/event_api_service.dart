import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class EventApiService {
  static const String baseUrl = 'https://api.welvors.com/api';

  // Hardcoded token for now as per other api services
  static const String _token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  static Future<Map<String, dynamic>?> getEvents({
    String? eventType,
    String? dateFilter,
    bool? freeOnly,
  }) async {
    try {
      String urlString = '$baseUrl/admin/events/get';
      List<String> queryParams = [];

      if (eventType != null && eventType.isNotEmpty && eventType != 'ALL') {
        queryParams.add('eventType=$eventType');
      }
      if (dateFilter != null && dateFilter.isNotEmpty) {
        queryParams.add('dateFilter=$dateFilter');
      }
      if (freeOnly == true) {
        queryParams.add('freeOnly=true');
      }

      if (queryParams.isNotEmpty) {
        urlString += '?${queryParams.join('&')}';
      }
      final url = Uri.parse(urlString);
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to get events: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting events: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getEventDetails(String eventId) async {
    try {
      final url = Uri.parse('$baseUrl/admin/events/details/$eventId');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to get event details: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting event details: $e');
      return null;
    }
  }
  static Future<Map<String, dynamic>?> getChatConversations() async {
    try {
      final url = Uri.parse('$baseUrl/user/chat/conversations');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failed to get chat conversations: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting chat conversations: $e');
      return null;
    }
  }
}
