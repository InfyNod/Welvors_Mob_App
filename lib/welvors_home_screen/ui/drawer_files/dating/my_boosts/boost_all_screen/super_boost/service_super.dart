import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../../services/token_helper.dart';

import 'package:velvors/config/env_config.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class SuperBoostApiService {
  static String get _baseUrl => '${EnvConfig.apiBaseUrl}/admin/boost/get-all?type=SUPER';

  Future<Map<String, dynamic>?> getSuperBoostsData() async {
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
      AppLogger.e('SuperBoostApiService', 'Error fetching super boosts data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSuperBoostWalletDetails() async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/admin/my-boost/boost_wallet?type=SUPER'),
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
      AppLogger.e('SuperBoostApiService', 'Error fetching super boost wallet details: $e');
      return null;
    }
  }
}
