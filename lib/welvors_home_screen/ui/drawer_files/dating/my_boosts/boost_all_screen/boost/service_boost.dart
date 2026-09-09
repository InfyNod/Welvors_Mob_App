import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../../services/token_helper.dart';

class BoostApiService {
  static const String _baseUrl = 'https://api.welvors.com/api/admin/boost/get-all';

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
}
