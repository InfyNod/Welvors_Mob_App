import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/token_helper.dart';

import 'package:velvors/config/env_config.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class WalletApiService {
  static String get _baseUrl => '${EnvConfig.apiBaseUrl}/user/my-wallet';

  Future<Map<String, dynamic>?> getWalletData({
    String filter = 'ALL',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final uri = Uri.parse('$_baseUrl?filter=$filter&page=$page&limit=$limit');
      
      final response = await http.get(
        uri,
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
      AppLogger.e('WalletApiService', 'Error fetching wallet data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getMyBalances() async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final uri = Uri.parse('${EnvConfig.apiBaseUrl}/user/my-balances');
      
      final response = await http.get(
        uri,
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
      AppLogger.e('WalletApiService', 'Error fetching my balances: $e');
      return null;
      return null;
    }
  }

  Future<bool> addMoney(int amount) async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final uri = Uri.parse('${EnvConfig.apiBaseUrl}/user/wallet/add-money');
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'amount': amount}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      AppLogger.e('WalletApiService', 'Error adding money: $e');
      return false;
    }
  }
}
