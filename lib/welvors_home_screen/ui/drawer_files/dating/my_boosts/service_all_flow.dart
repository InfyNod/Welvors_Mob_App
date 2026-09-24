import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/token_helper.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class BoostAllApiService {
  static const String _baseUrlBoost = 'https://api.welvors.com/api/admin/boost/get-all?type=BOOST';
  static const String _baseUrlSuper = 'https://api.welvors.com/api/admin/boost/get-all?type=SUPER';

  Future<Map<String, dynamic>?> getBoostsData() async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.get(
        Uri.parse(_baseUrlBoost),
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
      AppLogger.e('BoostAllApiService', 'Error fetching boosts data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSuperBoostsData() async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.get(
        Uri.parse(_baseUrlSuper),
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
      AppLogger.e('BoostAllApiService', 'Error fetching super boosts data: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBoostWalletDetails() async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.get(
        Uri.parse('https://api.welvors.com/api/admin/my-boost/boost_wallet?type=BOOST'),
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
      AppLogger.e('BoostAllApiService', 'Error fetching boost wallet details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSuperBoostWalletDetails() async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.get(
        Uri.parse('https://api.welvors.com/api/admin/my-boost/boost_wallet?type=SUPER'),
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
      AppLogger.e('BoostAllApiService', 'Error fetching super boost wallet details: $e');
      return null;
    }
  }

  Future<String?> activateBoost(String userBoostId, {String type = 'BOOST'}) async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.post(
        Uri.parse('https://api.welvors.com/api/user/boost/activate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_boost_id': userBoostId,
        }),
      );

      AppLogger.d('BoostAllApiService', 'Activate Boost Response Code: ${response.statusCode}');
      AppLogger.d('BoostAllApiService', 'Activate Boost Response Body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final usageId = data['data']?['id']?.toString();
          return usageId ?? ""; // If there's no id for some reason, return empty string so it's not null (truthy)
        }
      }
      return null;
    } catch (e) {
      AppLogger.e('BoostAllApiService', 'Error activating boost: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBoostHistory() async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.get(
        Uri.parse('https://api.welvors.com/api/user/boost/history'),
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
      AppLogger.e('BoostAllApiService', 'Error fetching boost history: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getBoostPerformance(String usageId) async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.get(
        Uri.parse('https://api.welvors.com/api/user/boost/performance/$usageId'),
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
      AppLogger.e('BoostAllApiService', 'Error fetching boost performance: $e');
      return null;
    }
  }
}
