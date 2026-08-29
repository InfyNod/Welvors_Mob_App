import 'dart:convert';
import 'package:http/http.dart' as http;

class AdmirersApiService {
  static const String baseUrl = 'https://api.welvors.com/api/user/admirers';
  // Standard token provided by the user
  static const String _token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs';

  /// Fetches Received Likes
  Future<Map<String, dynamic>> getReceivedLikes({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl?type=LIKE&direction=RECEIVED&page=$page&limit=$limit');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load admirers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching admirers: $e');
    }
  }
}
