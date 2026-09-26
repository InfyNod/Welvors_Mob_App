import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/token_helper.dart';

class ComplimentApiService {
  static const String _baseUrl = 'https://api.welvors.com/api/admin/purchase-store/data/COMPLIMENT';

  Future<Map<String, dynamic>?> getComplimentsData() async {
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
      print('Error fetching compliments data: $e');
      return null;
    }
  }

  Future<bool> buyComplimentPack(String packId) async {
    const String topUpUrl = 'https://api.welvors.com/api/user/compliment/wallet/top-up';
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.post(
        Uri.parse(topUpUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'packId': packId,
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
      print('Error buying compliment pack: $e');
      return false;
    }
  }
}
