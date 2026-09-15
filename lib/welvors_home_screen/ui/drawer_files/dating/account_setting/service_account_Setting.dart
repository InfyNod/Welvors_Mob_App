import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../../../services/token_helper.dart';

class AccountSettingService {
  static const String baseUrl = 'https://api.welvors.com/api';

  static Future<Map<String, String>> get _headers async {
    final token = await TokenHelper.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<bool> updateNotificationSettings({
    required bool newMatchesEnabled,
    required bool messagesEnabled,
    required bool likesRosesEnabled,
    required bool eventsEnabled,
    required bool promotionsEnabled,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/user/notification/settings');
      
      final body = jsonEncode({
        "newMatchesEnabled": newMatchesEnabled,
        "messagesEnabled": messagesEnabled,
        "likesRosesEnabled": likesRosesEnabled,
        "eventsEnabled": eventsEnabled,
        "promotionsEnabled": promotionsEnabled
      });

      final response = await http.patch(
        url,
        headers: await _headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Notification settings updated successfully');
        return true;
      } else {
        debugPrint('Failed to update notification settings: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error in updateNotificationSettings: $e');
      return false;
    }
  }
  static Future<bool> addBankOrUpi(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/user/bank-upi/create');
      final response = await http.post(
        url,
        headers: await _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Bank/UPI added successfully');
        return true;
      } else {
        debugPrint('Failed to add Bank/UPI: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error in addBankOrUpi: $e');
      return false;
    }
  }
  static Future<Map<String, dynamic>?> getBankAndUpi() async {
    try {
      final url = Uri.parse('$baseUrl/user/bank-upi/get');
      final response = await http.get(
        url,
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to get Bank/UPI: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error in getBankAndUpi: $e');
      return null;
    }
  }
}
