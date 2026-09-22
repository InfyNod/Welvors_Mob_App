import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/token_helper.dart';

import 'package:velvors/config/env_config.dart';

class RoseApiService {
  static String get _baseUrl => '${EnvConfig.apiBaseUrl}/admin/purchase-store/data/ROSE';

  Future<Map<String, dynamic>?> getRosesData() async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('Error fetching roses data: $e');
      return null;
    }
  }
}
