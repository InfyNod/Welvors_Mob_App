import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/token_helper.dart';

import 'package:velvors/config/env_config.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

class AccountSettingService {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  static Future<Map<String, String>> get _headers async {
    final token = await TokenHelper.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<bool> pauseAccount({required String reason}) async {
    try {
      final url = Uri.parse('$baseUrl/user/account/pause');
      final response = await http.patch(
        url,
        headers: await _headers,
        body: jsonEncode({"reason": reason}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('AccountSettingService', 'Account paused successfully');
        return true;
      } else {
        AppLogger.e('AccountSettingService', 'Failed to pause account: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in pauseAccount: $e');
      return false;
    }
  }

  static Future<String?> resumeAccount() async {
    try {
      final url = Uri.parse('$baseUrl/user/account/resume');
      final response = await http.patch(
        url,
        headers: await _headers,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('AccountSettingService', 'Account resumed successfully');
        return null; // success
      } else {
        AppLogger.e('AccountSettingService', 'Failed to resume account: ${response.statusCode} - ${response.body}');
        return response.body;
      }
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in resumeAccount: $e');
      return e.toString();
    }
  }

  static Future<bool> deleteAccount() async {
    try {
      final url = Uri.parse('$baseUrl/user/account/delete');
      final response = await http.delete(
        url,
        headers: await _headers,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('AccountSettingService', 'Account deleted successfully');
        return true;
      } else {
        AppLogger.e('AccountSettingService', 'Failed to delete account: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in deleteAccount: $e');
      return false;
    }
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
        AppLogger.i('AccountSettingService', 'Notification settings updated successfully');
        return true;
      } else {
        AppLogger.e('AccountSettingService', 'Failed to update notification settings: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in updateNotificationSettings: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getNotificationSettings() async {
    try {
      final url = Uri.parse('$baseUrl/user/notification/settings');
      final response = await http.get(
        url,
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          // If structure is just the data directly
          return data;
        }
      } else {
        AppLogger.e('AccountSettingService', 'Failed to get notification settings: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in getNotificationSettings: $e');
      return null;
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
        AppLogger.i('AccountSettingService', 'Bank/UPI added successfully');
        return true;
      } else {
        AppLogger.e('AccountSettingService', 'Failed to add Bank/UPI: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in addBankOrUpi: $e');
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
        AppLogger.e('AccountSettingService', 'Failed to get Bank/UPI: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in getBankAndUpi: $e');
      return null;
    }
  }

  static Future<bool> updateBankOrUpi(String id, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/user/bank-upi/update/$id');
      final response = await http.patch(
        url,
        headers: await _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('AccountSettingService', 'Bank/UPI updated successfully');
        return true;
      } else {
        AppLogger.e('AccountSettingService', 'Failed to update Bank/UPI: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in updateBankOrUpi: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getPrivacyControls() async {
    try {
      final url = Uri.parse('$baseUrl/user/privacy-controls/get');
      final response = await http.get(
        url,
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in getPrivacyControls: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getMembershipPlan() async {
    try {
      final url = Uri.parse('$baseUrl/user/membership-plan');
      final response = await http.get(
        url,
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in getMembershipPlan: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getMembershipInvoice(String userPackageId) async {
    try {
      final url = Uri.parse('$baseUrl/user/membership-plan/invoice/$userPackageId');
      final response = await http.get(
        url,
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in getMembershipInvoice: $e');
      return null;
    }
  }

  static Future<List<int>?> downloadInvoicePdf(String pdfUrl) async {
    try {
      final url = Uri.parse('$baseUrl${pdfUrl.replaceFirst('/api', '')}');
      final response = await http.get(
        url,
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        AppLogger.e('AccountSettingService', 'Failed PDF download: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in downloadInvoicePdf: $e');
      return null;
    }
  }

  static Future<bool> updatePrivacyControls(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/user/privacy-controls/update');
      final response = await http.patch(
        url,
        headers: await _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('AccountSettingService', 'Privacy controls updated successfully');
        return true;
      } else {
        AppLogger.e('AccountSettingService', 'Failed to update privacy controls: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in updatePrivacyControls: $e');
      return false;
    }
  }

  static Future<List<dynamic>?> getBlockedUsers() async {
    try {
      final url = Uri.parse('$baseUrl/user/blocked-users/list');
      final response = await http.get(url, headers: await _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data']; // Assuming 'data' contains the list of blocked users
        }
      }
      return null;
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in getBlockedUsers: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getMutedUsers() async {
    try {
      final url = Uri.parse('$baseUrl/user/notification/muted-users');
      final response = await http.get(url, headers: await _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data']; // Assuming 'data' contains the list of muted users
        }
      }
      return null;
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in getMutedUsers: $e');
      return null;
    }
  }

  static Future<bool> unblockUser(String blockedId) async {
    try {
      final url = Uri.parse('$baseUrl/user/unblock/$blockedId');
      final response = await http.delete(url, headers: await _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('AccountSettingService', 'User unblocked successfully');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in unblockUser: $e');
      return false;
    }
  }

  static Future<bool> unmuteUser(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/user/notification/users/$userId/unmute');
      final response = await http.patch(url, headers: await _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('AccountSettingService', 'User unmuted successfully');
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in unmuteUser: $e');
      return false;
    }
  }

  static Future<bool> setPrimaryBankUpi(String id) async {
    try {
      final url = Uri.parse('$baseUrl/user/bank-upi/$id/primary');
      final response = await http.patch(
        url,
        headers: await _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.i('AccountSettingService', 'Bank/UPI set as primary successfully');
        return true;
      } else {
        AppLogger.e('AccountSettingService', 'Failed to set primary Bank/UPI: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in setPrimaryBankUpi: $e');
      return false;
    }
  }

  static Future<bool> removeBankUpi(String id) async {
    try {
      final url = Uri.parse('$baseUrl/user/bank-upi/$id/remove');
      final response = await http.delete(
        url,
        headers: await _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        AppLogger.i('AccountSettingService', 'Bank/UPI removed successfully');
        return true;
      } else {
        AppLogger.e('AccountSettingService', 'Failed to remove Bank/UPI: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      AppLogger.e('AccountSettingService', 'Error in removeBankUpi: $e');
      return false;
    }
  }
}
