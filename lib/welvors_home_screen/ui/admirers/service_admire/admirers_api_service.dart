import 'dart:convert';
import '../../../services/token_helper.dart';
import 'package:http/http.dart' as http;

class AdmirersApiService {
  static const String baseUrl = 'https://api.welvors.com/api/user/admirers';

  /// Fetches Received Likes
  Future<Map<String, dynamic>> getReceivedLikes({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl?type=LIKE&direction=RECEIVED&page=$page&limit=$limit');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await TokenHelper.getToken() ?? ""}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load received admirers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching received admirers: $e');
    }
  }

  /// Fetches Sent Likes
  Future<Map<String, dynamic>> getSentLikes({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl?type=LIKE&direction=SENT&page=$page&limit=$limit');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await TokenHelper.getToken() ?? ""}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load sent admirers. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sent admirers: $e');
    }
  }

  /// Fetches Received Roses
  Future<Map<String, dynamic>> getReceivedRoses({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl?type=ROSE&direction=RECEIVED&page=$page&limit=$limit');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await TokenHelper.getToken() ?? ""}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load received roses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching received roses: $e');
    }
  }

  /// Fetches Sent Roses
  Future<Map<String, dynamic>> getSentRoses({int page = 1, int limit = 10}) async {
    final url = Uri.parse('$baseUrl?type=ROSE&direction=SENT&page=$page&limit=$limit');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await TokenHelper.getToken() ?? ""}',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load sent roses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching sent roses: $e');
    }
  }
}
