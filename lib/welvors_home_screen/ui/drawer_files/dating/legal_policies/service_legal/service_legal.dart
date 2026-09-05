import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class LegalApiService {
  static const String _baseUrl = 'https://api.welvors.com/api/legal/legal-pages';

  Future<Map<String, dynamic>?> getLegalPage(String pageType) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/$pageType'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      } else {
        debugPrint('Failed to load $pageType: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching $pageType: $e');
    }
    return null;
  }
}
