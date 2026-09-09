import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/token_helper.dart';

class CommitmentApiService {
  static const String _baseUrl = 'https://api.welvors.com/api/user/relationship-tags/commitment-management';

  Future<Map<String, dynamic>?> getCommitmentData() async {
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
      print('Error fetching commitment data: $e');
      return null;
    }
  }
}
