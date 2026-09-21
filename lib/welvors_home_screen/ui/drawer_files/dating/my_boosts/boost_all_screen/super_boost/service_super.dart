import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../../services/token_helper.dart';

class SuperBoostApiService {
  static const String _baseUrl =
      'https://api.welvors.com/api/admin/boost/get-all?type=SUPER';

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
      print('Error fetching super boosts data: $e');
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
      print('Error fetching super boost wallet details: $e');
      return null;
    }
  }
}
