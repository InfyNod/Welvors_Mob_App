import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://dating-app-backend-plum.vercel.app/api';

  /// Fetches onboarding intentions from the server.
  /// Returns a map containing 'title', 'description', and 'options' list.
  static Future<Map<String, dynamic>> fetchIntentions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/onboarding/intention/get'));
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null && decoded['data'].isNotEmpty) {
          final data = decoded['data'][0];
          
          List<Map<String, dynamic>> parsedOptions = [];
          if (data['options'] != null) {
            final List<dynamic> optionsRaw = data['options'];
            parsedOptions = optionsRaw.map((opt) {
              return {
                'id': opt['id'] ?? '',
                'intentionId': opt['intentionId'] ?? '',
                'title': opt['option'] ?? '',
                'subtitle': opt['optDescription'] ?? '',
              };
            }).toList();
          }
          
          return {
            'title': data['title'] ?? '',
            'description': data['description'] ?? '',
            'options': parsedOptions,
          };
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching intentions: $e');
      return {};
    }
  }

  /// Fetches prompt categories and their prompts from the server.
  static Future<List<dynamic>> fetchPromptsCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/onboarding/prompt/get'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return decoded['data'];
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching prompts categories: $e');
      return [];
    }
  }

  /// Fetches referral dashboard data.
  static Future<Map<String, dynamic>?> fetchReferralDashboard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/user/referral/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Referral Dashboard Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          return decoded['data'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching referral dashboard: $e');
      return null;
    }
  }

  /// Fetches Refer & Earn informational details (e.g., rewards and rules).
  static Future<Map<String, dynamic>?> fetchReferEarnInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/onboarding/referEarn/get'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Refer Earn Info Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return decoded['data'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching refer earn info: $e');
      return null;
    }
  }

  /// Fetches waitlist offer details for the Founding Batch screen.
  static Future<Map<String, dynamic>?> fetchWaitlistOffer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/user/waitlist/get'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Waitlist Offer Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return decoded['data'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching waitlist offer: $e');
      return null;
    }
  }

  /// Applies a referral code.
  static Future<Map<String, dynamic>?> applyReferralCode(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('$baseUrl/user/apply-referral'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'referralCode': code}),
      );

      debugPrint('Apply Referral Status: ${response.statusCode}');
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Error applying referral code: $e');
      return {'success': false, 'message': 'Network error occurred'};
    }
  }

  /// Fetches lifestyle questions from the server.
  static Future<List<Map<String, dynamic>>> fetchLifestyle() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/question/fetch?category=DATING&screen=LIFESTYLE'));
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final List<dynamic> data = decoded['data'];
          return data.map((q) {
            final List<dynamic> optionsRaw = q['options'] ?? [];
            return {
              'id': q['id'] ?? '',
              'key': q['key'] ?? '',
              'title': q['title'] ?? '',
              'isMulti': q['isMulti'] ?? false,
              'options': optionsRaw.map((opt) => {
                'id': opt['id'] ?? '',
                'value': opt['value'] ?? '',
                'label': opt['label'] ?? '',
              }).toList(),
            };
          }).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching lifestyle: $e');
      return [];
    }
  }

  /// Completes the user onboarding profile.
  static Future<bool> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/complete-onboarding'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      debugPrint('Complete Onboarding: ${response.statusCode} - ${response.body}');
      return (response.statusCode == 200 || response.statusCode == 201);
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      return false;
    }
  }

  /// Fetches things you love (interests) questions from the server.
  static Future<List<dynamic>> fetchInterests() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/question/fetch?category=DATING&screen=THINGS_U_LOVE'));
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return decoded['data'];
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching interests: $e');
      return [];
    }
  }

  /// Fetches profession options from the server.
  static Future<Map<String, int>> fetchProfessions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/onboarding/professions/get'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final List<dynamic> data = decoded['data'];
          final Map<String, int> map = {};
          for (var item in data) {
            map[item['name'].toString()] = item['id'] as int;
          }
          return map;
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching professions: $e');
      return {};
    }
  }

  /// Fetches experience options from the server.
  static Future<Map<String, int>> fetchExperiences() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/onboarding/experiences/get'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final List<dynamic> data = decoded['data'];
          final Map<String, int> map = {};
          for (var item in data) {
            map[item['title'].toString()] = item['id'] as int;
          }
          return map;
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching experiences: $e');
      return {};
    }
  }

  /// Fetches employment type options from the server.
  static Future<Map<String, int>> fetchEmploymentTypes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/onboarding/employment-type/get'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final List<dynamic> data = decoded['data'];
          final Map<String, int> map = {};
          for (var item in data) {
            map[item['name'].toString()] = item['id'] as int;
          }
          return map;
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching employment types: $e');
      return {};
    }
  }

  /// Fetches salary ranges from the server.
  static Future<Map<String, int>> fetchSalaryRanges() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/onboarding/salary-ranges/get'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final List<dynamic> data = decoded['data'];
          final Map<String, int> map = {};
          for (var item in data) {
            map[item['title'].toString()] = item['id'] as int;
          }
          return map;
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching salary ranges: $e');
      return {};
    }
  }

  /// Fetches ambition options from the server.
  static Future<Map<String, int>> fetchAmbitions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/onboarding/ambitions/get'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final List<dynamic> data = decoded['data'];
          final Map<String, int> map = {};
          for (var item in data) {
            map[item['title'].toString()] = item['id'] as int;
          }
          return map;
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching ambitions: $e');
      return {};
    }
  }

  /// Sends OTP to the given phone number.
  static Future<String?> sendOtp(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );
      
      debugPrint('OTP Send: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) return null;
        return decoded['message'] ?? 'Failed to send OTP';
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      return e.toString();
    }
  }

  /// Validates a referral code.
  static Future<Map<String, dynamic>?> validateReferralCode(String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/referral-validate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'referralCode': code}),
      );
      
      debugPrint('Referral Validate: ${response.statusCode} - ${response.body}');
      try {
        return jsonDecode(response.body);
      } catch (_) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          return {'success': true};
        }
        return null;
      }
    } catch (e) {
      debugPrint('Error validating referral code: $e');
      return null;
    }
  }

  /// Verifies OTP and returns the token or error string.
  static Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp, [String? referralCode]) async {
    try {
      final body = {
        'phoneNumber': phoneNumber,
        'otp': otp,
      };
      if (referralCode != null && referralCode.isNotEmpty) {
        body['referralCode'] = referralCode;
      }
      final response = await http.post(
        Uri.parse('$baseUrl/user/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      debugPrint('OTP Verify: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['token'] != null) {
          return {'token': decoded['token'].toString(), 'error': null};
        }
        return {'token': null, 'error': decoded['message'] ?? 'Failed to verify'};
      }
      return {'token': null, 'error': 'Error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      return {'token': null, 'error': e.toString()};
    }
  }

  /// Submits the basic info to the server.
  static Future<String?> submitBasicInfo(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/basic-info'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      debugPrint('Basic Info Status: ${response.statusCode}');
      debugPrint('Basic Info Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
           return null; // Success
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      
      try {
        final decoded = jsonDecode(response.body);
        return decoded['message'] ?? 'Error ${response.statusCode}: ${response.body}';
      } catch (_) {
        return 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      debugPrint('Error submitting basic info: $e');
      return e.toString();
    }
  }

  /// Submits the interested-in preference to the server.
  static Future<String?> submitInterestedIn(String interestedIn) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/interested-in'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'interested_in': interestedIn}),
      );

      debugPrint('Interested In Status: ${response.statusCode}');
      debugPrint('Interested In Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
           return null; // Success
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      
      try {
        final decoded = jsonDecode(response.body);
        return decoded['message'] ?? 'Error ${response.statusCode}: ${response.body}';
      } catch (_) {
        return 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      debugPrint('Error submitting interested in: $e');
      return e.toString();
    }
  }

  /// Submits the looking-for intention to the server.
  static Future<String?> submitLookingFor(String intentionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/looking-for'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'intentionId': intentionId}),
      );

      debugPrint('Looking For Status: ${response.statusCode}');
      debugPrint('Looking For Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
           return null; // Success
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      
      try {
        final decoded = jsonDecode(response.body);
        return decoded['message'] ?? 'Error ${response.statusCode}: ${response.body}';
      } catch (_) {
        return 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      debugPrint('Error submitting looking for: $e');
      return e.toString();
    }
  }

  /// Submits an answer for a specific question.
  static Future<String?> submitAnswer({
    required String questionId,
    required List<String> optionIds,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/answer'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'questionId': questionId,
          'optionIds': optionIds,
        }),
      );

      debugPrint('Submit Answer Status: ${response.statusCode}');
      debugPrint('Submit Answer Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
           return null; // Success
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      
      try {
        final decoded = jsonDecode(response.body);
        return decoded['message'] ?? 'Error ${response.statusCode}: ${response.body}';
      } catch (_) {
        return 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      debugPrint('Error submitting answer: $e');
      return e.toString();
    }
  }

  /// Submits the education info to the server.
  static Future<String?> submitEducation(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/education'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      debugPrint('Submit Education Status: ${response.statusCode}');
      debugPrint('Submit Education Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
           return null;
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error submitting education: $e');
      return e.toString();
    }
  }

  /// Submits the work info to the server.
  static Future<String?> submitWork(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/work'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      debugPrint('Submit Work Status: ${response.statusCode}');
      debugPrint('Submit Work Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
           return null;
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error submitting work: $e');
      return e.toString();
    }
  }

  /// Submits the user's photos to the server.
  static Future<String?> submitPhotos(List<String> imagePaths) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/user/profile/photos'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      for (var path in imagePaths) {
        request.files.add(
          await http.MultipartFile.fromPath('images', path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Submit Photos Status: ${response.statusCode}');
      debugPrint('Submit Photos Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
           return null; // Success
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      
      try {
        final decoded = jsonDecode(response.body);
        return decoded['message'] ?? 'Error ${response.statusCode}: ${response.body}';
      } catch (_) {
        return 'Error ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      debugPrint('Error submitting photos: $e');
      return e.toString();
    }
  }

  /// Submits the user's bio to the server.
  static Future<String?> submitBio(String bioText) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/bio'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "bio": bioText
        }),
      );

      debugPrint('Submit Bio Status: ${response.statusCode}');
      debugPrint('Submit Bio Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
           return null;
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error submitting bio: $e');
      return e.toString();
    }
  }

  /// Submits the user's prompts to the server.
  static Future<String?> submitPrompts(List<Map<String, String>> prompts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/prompts'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "prompts": prompts
        }),
      );

      debugPrint('Submit Prompts Status: ${response.statusCode}');
      debugPrint('Submit Prompts Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
           return null;
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error submitting prompts: $e');
      return e.toString();
    }
  }

  /// Submits the user's address.
  static Future<String?> submitAddress(String country, String state, String city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/address'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "country": country,
          "state": state,
          "city": city,
        }),
      );

      debugPrint('Submit Address Status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error submitting address: $e');
      return e.toString();
    }
  }

  /// Submits the user's GPS coordinates.
  static Future<String?> submitLocation(double lat, double lng) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/location'), // Fixed URL typo
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "latitude": lat,
          "longitude": lng,
        }),
      );

      debugPrint('Submit Location Status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error submitting location: $e');
      return e.toString();
    }
  }
}
