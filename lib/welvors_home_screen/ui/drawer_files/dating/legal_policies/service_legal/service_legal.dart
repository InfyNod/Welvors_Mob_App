import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:velvors/config/env_config.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

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
        AppLogger.e('LegalApiService', 'Failed to load $pageType: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.e('LegalApiService', 'Error fetching $pageType: $e');
    }
    return null;
  }
}
