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

  Future<bool> endCommitment(String relationshipId) async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final url = 'https://api.welvors.com/api/user/relationship-tags/$relationshipId/end';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error ending commitment: $e');
      return false;
    }
  }

  Future<List<dynamic>?> getReceivedProposals() async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      const url = 'https://api.welvors.com/api/user/relationship-tags/received-proposals';
      
      final response = await http.get(
        Uri.parse(url),
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
      print('Error fetching received proposals: $e');
      return null;
    }
  }

  Future<bool> respondToProposal(String proposalId, bool accept) async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final action = accept ? 'accept' : 'reject';
      final url = 'https://api.welvors.com/api/user/relationship-tags/proposals/$proposalId/$action';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error responding to proposal: $e');
      return false;
    }
  }
}
