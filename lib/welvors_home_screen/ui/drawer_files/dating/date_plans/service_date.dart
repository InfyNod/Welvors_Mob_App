import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/token_helper.dart';

import 'package:velvors/config/env_config.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class DatePlanApiService {
  static String get _baseUrl => '${EnvConfig.apiBaseUrl}/user/date-now/date-plan-packages/get-all';

  Future<Map<String, dynamic>?> getDatePlansData() async {
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
      AppLogger.e('DatePlanApiService', 'Error fetching date plans data: $e');
      return null;
    }
  }
}
