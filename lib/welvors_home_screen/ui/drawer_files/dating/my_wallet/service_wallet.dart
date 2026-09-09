import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/token_helper.dart';

class WalletApiService {
  static const String _baseUrl = 'https://api.welvors.com/api/user/my-wallet';

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
      print('Error fetching wallet data: $e');
      return null;
    }
  }
}
