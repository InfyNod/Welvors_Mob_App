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

  Future<bool> buyDatePlanPack(String packageId) async {
    const String topUpUrl = 'https://api.welvors.com/api/user/date-plan/wallet/top-up';
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.post(
        Uri.parse(topUpUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'packageId': packageId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      AppLogger.e('DatePlanApiService', 'Error buying date plan pack: $e');
      return false;
    }
  }
}
