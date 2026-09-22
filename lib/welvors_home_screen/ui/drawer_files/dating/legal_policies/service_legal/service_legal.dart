import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:velvors/config/env_config.dart';

class LegalApiService {
  static String get _baseUrl => '${EnvConfig.apiBaseUrl}/legal/legal-pages';

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
