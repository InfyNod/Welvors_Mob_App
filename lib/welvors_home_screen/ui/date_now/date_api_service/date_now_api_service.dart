import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class DateNowApiService {
  static const String baseUrl = 'https://api.welvors.com/api';
  static const String vercelBaseUrl = 'https://dating-app-backend-plum.vercel.app/api';

  // Hardcoded token for now as per home_api_service.dart pattern
  static const String _token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs';

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  // Example structure for API methods. You can provide the endpoints and I'll fill them in!

  // POST Request Example
  static Future<Map<String, dynamic>?> postPlan(
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plans');
      final response = await http.post(
        url,
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint(
          'Failed to post plan: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Error posting plan: $e');
      return null;
    }
  }

  // PATCH Request for Step 2 and 3
  static Future<Map<String, dynamic>?> patchPlan(
    String planId,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plans/$planId');
      final response = await http.patch(
        url,
        headers: _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint(
          'Failed to patch plan: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Error patching plan: $e');
      return null;
    }
  }

  // POST Request to publish the plan (Step 4)
  static Future<Map<String, dynamic>?> publishPlan(String planId) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plans/$planId/publish');
      final response = await http.post(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint(
          'Failed to publish plan: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Error publishing plan: $e');
      return null;
    }
  }

  // Generic GET Options (for ACTIVITY, QUICK_TITLE, VIBE)
  static Future<List<dynamic>?> getOptions(String type) async {
    try {
      final url = Uri.parse('$baseUrl/admin/date-now/options?type=$type');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          return decoded['data'] as List<dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting options for $type: $e');
      return null;
    }
  }

  // GET Request to fetch history
  static Future<Map<String, dynamic>?> getHistoryPlans({int page = 1, int limit = 10}) async {
    try {
      final url = Uri.parse('$vercelBaseUrl/user/date-plans/history?page=$page&limit=$limit');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint(
          'Failed to fetch history plans: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching history plans: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getDiscoverPlans(
    String filter, {
    String? overrideToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plans/discover?filter=$filter');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${overrideToken ?? _token}',
      };

      final response = await http.get(url, headers: headers);

      debugPrint(
        'Discover API Response [${response.statusCode}]: ${response.body}',
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          final data = decoded['data'];
          if (data is List) {
            return data;
          } else if (data is Map) {
            return [data];
          }
          return [];
        }
      } else {
        debugPrint(
          'Failed to get discover plans: ${response.statusCode} - ${response.body}',
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching discover plans: $e');
      return null;
    }
  }

  // POST Request to skip a plan
  static Future<bool> skipPlan(String planId, {String? overrideToken}) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plans/$planId/skip');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${overrideToken ?? _token}',
      };

      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          'Failed to skip plan: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error skipping plan: $e');
      return false;
    }
  }

  // POST Request to send date request
  static Future<bool> requestDatePlan(
    String planId, {
    String? overrideToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plans/$planId/request');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${overrideToken ?? _token}',
      };

      final response = await http.post(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          'Failed to request plan: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error requesting plan: $e');
      return false;
    }
  }

  // PATCH Request to approve date request
  static Future<bool> approveRequest(String requestId) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plan-requests/$requestId/approve');
      final response = await http.patch(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Failed to approve request: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error approving request: $e');
      return false;
    }
  }

  // PATCH Request to decline date request
  static Future<bool> declineRequest(String requestId) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plan-requests/$requestId/decline');
      final response = await http.patch(url, headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Failed to decline request: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error declining request: $e');
      return false;
    }
  }

  // Request to withdraw a sent request
  static Future<bool> withdrawRequest(String requestId, {String? overrideToken}) async {
    try {
      // The user mentioned the API is on the vercel domain, which might not be deployed to production yet
      final String vercelBaseUrl = 'https://dating-app-backend-plum.vercel.app/api'; //vercel link api
      final url = Uri.parse('$vercelBaseUrl/user/date-plans/withdraw/$requestId');
      
      final headers = overrideToken != null 
          ? {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $overrideToken',
            }
          : _headers;
      
      // We assume it's PATCH based on the other endpoints, but fallback to POST/DELETE
      var response = await http.patch(url, headers: headers);
      debugPrint('PATCH vercel response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) return true;
      if (response.body.contains('"success":') || response.body.contains('not found')) return false;

      // If 404 HTML, try POST on Vercel
      if (response.statusCode == 404) {
        response = await http.post(url, headers: headers);
        debugPrint('POST vercel response: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 200 || response.statusCode == 201) return true;
        if (response.body.contains('"success":') || response.body.contains('not found')) return false;
      }
      
      // Try DELETE on Vercel
      if (response.statusCode == 404) {
        response = await http.delete(url, headers: headers);
        debugPrint('DELETE vercel response: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 200 || response.statusCode == 201) return true;
        if (response.body.contains('"success":') || response.body.contains('not found')) return false;
      }

      return false;
    } catch (e) {
      debugPrint('Error withdrawing request: $e');
      return false;
    }
  }

  // GET Request to fetch requests for a specific plan
  static Future<Map<String, dynamic>?> getPlanRequests(String planId) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plans/$planId/requests');
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      } else {
        debugPrint('Failed to fetch plan requests: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching plan requests: $e');
      return null;
    }
  }
}
