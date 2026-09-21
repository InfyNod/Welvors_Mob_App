import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../../services/token_helper.dart';

import 'package:velvors/config/env_config.dart';

class BoostApiService {
  static String get _baseUrl => '${EnvConfig.apiBaseUrl}/admin/boost/get-all?type=BOOST';

  Future<Map<String, dynamic>?> getBoostsData() async {
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
      print('Error fetching boosts data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBoostWalletDetails() async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.get(
        Uri.parse('${EnvConfig.apiBaseUrl}/admin/my-boost/boost_wallet?type=BOOST'),
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
      print('Error fetching boost wallet details: $e');
      return null;
    }
  }
}
