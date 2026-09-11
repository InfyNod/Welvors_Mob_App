import '../../../services/token_helper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class DateNowApiService {
  static const String baseUrl = 'https://api.welvors.com/api';

  // Hardcoded token for now as per home_api_service.dart pattern
  static Future<Map<String, dynamic>?> inviteToDatePlan(
    String datePlanId,
    String receiverId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/date-plan/$datePlanId/invite'),
        headers: await _headers,
        body: jsonEncode({'receiverId': receiverId}),
      );

      debugPrint(
        'Date Plan Invite Status: ${response.statusCode} - ${response.body}',
      );
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error inviting to date plan: $e');
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  static Future<Map<String, String>> get _headers async {
    final token = await TokenHelper.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Example structure for API methods. You can provide the endpoints and I'll fill them in!

  static Future<Map<String, dynamic>?> getDatePlanBoosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/date-now/date-plan-boosts/get'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint(
          'Error getting boosts: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Exception getting boosts: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> activateDatePlanBoost(
    String planId,
    String boostOptionId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/date-plan-boost/$planId/activate'),
        headers: await _headers,
        body: jsonEncode({"boostOptionId": boostOptionId}),
      );

      debugPrint(
        'Activate Boost Status: ${response.statusCode} - ${response.body}',
      );
      return json.decode(response.body);
    } catch (e) {
      debugPrint('Exception activating boost: $e');
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  static Future<Map<String, dynamic>?> getActiveDatePlanBoost(
    String planId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/date-plan-boost/$planId/active'),
        headers: await _headers,
      );

      debugPrint(
        'Get Active Boost Status: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Exception getting active boost: $e');
      return null;
    }
  }

  // POST Request Example
  static Future<Map<String, dynamic>?> postPlan(
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plans');
      final response = await http.post(
        url,
        headers: await _headers,
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
        headers: await _headers,
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

  // PATCH Request for Step 1 Activity
  static Future<Map<String, dynamic>?> patchPlanActivity(
    String planId,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plans/$planId/activity');
      final response = await http.patch(
        url,
        headers: await _headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint(
          'Failed to patch plan activity: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Error patching plan activity: $e');
      return null;
    }
  }

  // POST Request to publish the plan (Step 4)
  static Future<Map<String, dynamic>?> publishPlan(String planId) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plans/$planId/publish');
      final response = await http.post(url, headers: await _headers);

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
      final response = await http.get(url, headers: await _headers);

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
  static Future<Map<String, dynamic>?> getHistoryPlans({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/user/date-plans/history?page=$page&limit=$limit',
      );
      final response = await http.get(url, headers: await _headers);

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

  // GET Request to fetch history plan details
  static Future<Map<String, dynamic>?> getHistoryPlanDetails(
    String planId,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/user/history/details/$planId');
      final response = await http.get(url, headers: await _headers);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return decoded['data'] as Map<String, dynamic>?;
        }
        return decoded;
      } else {
        debugPrint(
          'Failed to fetch history details: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching history details: $e');
      return null;
    }
  }

  // GET Request to fetch my hosted plans (Today, Tomorrow, Weekend, Activity)
  static Future<Map<String, dynamic>?> getMyPlans({
    required String period,
    String? activity,
  }) async {
    try {
      String query = 'period=${period.toUpperCase()}';
      if (activity != null && activity.isNotEmpty) {
        query += '&activity=${activity.toLowerCase()}';
      }

      final url = Uri.parse('$baseUrl/user/date-plans/my-plans?$query');
      final response = await http.get(url, headers: await _headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint(
          'Failed to fetch my plans for $period: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching my plans: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getDiscoverPlans(
    String filter, {
    String? overrideToken,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/user/date-plans/discover?filter=$filter&limit=15',
      );

      final headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${overrideToken ?? (await TokenHelper.getToken() ?? "")}',
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
        'Authorization':
            'Bearer ${overrideToken ?? (await TokenHelper.getToken() ?? "")}',
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
    String? message,
    String? billSuggestionId,
    String? overrideToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plans/$planId/request');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${overrideToken ?? (await TokenHelper.getToken() ?? "")}',
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          if (message != null && message.isNotEmpty) 'message': message,
          if (billSuggestionId != null && billSuggestionId.isNotEmpty)
            'billSuggestionId': billSuggestionId,
        }),
      );

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
  static Future<Map<String, dynamic>> approveRequest(String requestId) async {
    try {
      final url = Uri.parse(
        '$baseUrl/user/date-plan-requests/$requestId/approve',
      );
      final response = await http.patch(url, headers: await _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        debugPrint(
          'Failed to approve request: ${response.statusCode} - ${response.body}',
        );
        try {
          final errorMsg = json.decode(response.body)['message'];
          return {
            'success': false,
            'message': errorMsg ?? 'Failed to approve request',
          };
        } catch (_) {
          return {'success': false, 'message': 'Failed to approve request'};
        }
      }
    } catch (e) {
      debugPrint('Error approving request: $e');
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  // PATCH Request to decline date request
  static Future<Map<String, dynamic>> declineRequest(String requestId) async {
    try {
      final url = Uri.parse(
        '$baseUrl/user/date-plan-requests/$requestId/decline',
      );
      final response = await http.patch(url, headers: await _headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        debugPrint(
          'Failed to decline request: ${response.statusCode} - ${response.body}',
        );
        try {
          final errorMsg = json.decode(response.body)['message'];
          return {
            'success': false,
            'message': errorMsg ?? 'Failed to decline request',
          };
        } catch (_) {
          return {'success': false, 'message': 'Failed to decline request'};
        }
      }
    } catch (e) {
      debugPrint('Error declining request: $e');
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  // Request to withdraw a sent request
  static Future<bool> withdrawRequest(
    String requestId, {
    String? overrideToken,
  }) async {
    try {
      // The user mentioned the API is on the backend domain, which might not be deployed to production yet
      final url = Uri.parse('$baseUrl/user/date-plans/withdraw/$requestId');

      final headers = overrideToken != null
          ? {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $overrideToken',
            }
          : await _headers;

      // We assume it's PATCH based on the other endpoints, but fallback to POST/DELETE
      var response = await http.patch(url, headers: headers);
      debugPrint('PATCH response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) return true;
      if (response.body.contains('"success":') ||
          response.body.contains('not found'))
        return false;

      // If 404 HTML, try POST on Vercel
      if (response.statusCode == 404) {
        response = await http.post(url, headers: headers);
        debugPrint('POST response: ${response.statusCode} - ${response.body}');
        if (response.statusCode == 200 || response.statusCode == 201)
          return true;
        if (response.body.contains('"success":') ||
            response.body.contains('not found'))
          return false;
      }

      // Try DELETE on Vercel
      if (response.statusCode == 404) {
        response = await http.delete(url, headers: headers);
        debugPrint(
          'DELETE response: ${response.statusCode} - ${response.body}',
        );
        if (response.statusCode == 200 || response.statusCode == 201)
          return true;
        if (response.body.contains('"success":') ||
            response.body.contains('not found'))
          return false;
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
      final response = await http.get(url, headers: await _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      } else {
        debugPrint(
          'Failed to fetch plan requests: ${response.statusCode} - ${response.body}',
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching plan requests: $e');
      return null;
    }
  }

  // POST Request for End & Review 1st screen
  static Future<bool> submitFeedbackIsMeet(String planId, String status) async {
    try {
      final url = Uri.parse('$baseUrl/user/$planId/feedback/is_meet');
      final response = await http.post(
        url,
        headers: await _headers,
        body: json.encode({'attendanceStatus': status}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          'Failed to submit feedback: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting feedback is_meet: $e');
      return false;
    }
  }

  // PUT Request for Who came to meet you screen
  static Future<bool> submitFeedbackMetUser(
    String planId,
    String metUserId,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/user/$planId/feedback/met-user');
      final response = await http.put(
        url,
        headers: await _headers,
        body: json.encode({'metUserId': metUserId}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          'Failed to submit feedback met-user: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting feedback met-user: $e');
      return false;
    }
  }

  // POST Request for Experience Rating screen
  static Future<bool> submitFeedbackExperience(
    String planId,
    int overallRating,
    int personRating,
    List<String> experienceTags,
  ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/user/date-plans/$planId/feedback/experience',
      );
      final response = await http.post(
        url,
        headers: await _headers,
        body: json.encode({
          'overallRating': overallRating,
          'personRating': personRating,
          'experienceTags': experienceTags,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          'Failed to submit experience rating: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting experience rating: $e');
      return false;
    }
  }

  // POST Request for No Show Rating screen
  static Future<bool> submitFeedbackNoShow(
    String planId,
    int overallRating,
    String noShowReason,
  ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/user/date-plans/$planId/feedback/no-show',
      );
      final response = await http.post(
        url,
        headers: await _headers,
        body: json.encode({
          'overallRating': overallRating,
          'noShowReason': noShowReason,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          'Failed to submit no-show rating: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting no-show rating: $e');
      return false;
    }
  }

  // POST Request for Report Issue
  static Future<bool> submitReportIssue(
    String planId,
    String reason,
    String comment,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plans/$planId/report');
      final response = await http.post(
        url,
        headers: await _headers,
        body: json.encode({'reason': reason, 'comment': comment}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          'Failed to submit report issue: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error submitting report issue: $e');
      return false;
    }
  }

  // PATCH Request for Cancel Date Plan
  static Future<bool> cancelDatePlan(String planId) async {
    try {
      final url = Uri.parse('$baseUrl/user/date-plan/$planId/cancel');
      final response = await http.patch(url, headers: await _headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          'Failed to cancel date plan: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error canceling date plan: $e');
      return false;
    }
  }

  // Fetch dynamic activity options
  static Future<List<dynamic>?> getActivityOptions() async {
    try {
      final url = Uri.parse('$baseUrl/admin/date-now/options?type=ACTIVITY');
      final response = await http.get(url, headers: await _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      debugPrint(
        'Failed to fetch activity options: ${response.statusCode} - ${response.body}',
      );
      return null;
    } catch (e) {
      debugPrint('Error fetching activity options: $e');
      return null;
    }
  }
}
