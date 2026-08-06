import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileApiService {
  // Update this baseUrl if it differs for your environment
  static const String baseUrl =
      'https://dating-app-backend-plum.vercel.app/api';

  /// Fetches family options (e.g. familyType)
  static Future<List<String>> getFamilyOptions(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = Uri.parse('$baseUrl/admin/family/options?type=$type');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['data'] != null) {
          List data = decoded['data'];
          return data.map((e) {
            if (e is String) return e;
            if (e is Map) {
              if (e.containsKey('value')) return e['value'].toString();
              if (e.containsKey('name')) return e['name'].toString();
            }
            return e.toString();
          }).toList();
        } else if (decoded is List) {
          return decoded.map((e) {
            if (e is String) return e;
            if (e is Map) {
              if (e.containsKey('value')) return e['value'].toString();
              if (e.containsKey('name')) return e['name'].toString();
            }
            return e.toString();
          }).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching family options for $type: $e');
      return [];
    }
  }

  /// Updates user location via PATCH
  static Future<Map<String, dynamic>> updateLocation({
    required String country,
    required String state,
    required String city,
    required String area,
    required double latitude,
    required double longitude,
    int maxDistanceKm = 25,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final url = Uri.parse('$baseUrl/user/edit-profile/location');
      final body = {
        "country": country,
        "state": state,
        "city": city,
        "area": area,
        "latitude": latitude,
        "longitude": longitude,
        "max_distance_km": maxDistanceKm,
      };

      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('Update Location Status: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'error': null, 'data': jsonDecode(response.body)};
      } else {
        return {'error': 'Failed: ${response.body}'};
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
      return {'error': e.toString()};
    }
  }

  /// Adds a single new photo to the server.
  static Future<Map<String, dynamic>> addPhoto(String imagePath) async {
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

      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          imagePath,
          filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
          return {'error': null, 'data': decoded}; // Success
        }
        return {'error': decoded['message'] ?? 'Failed: ${response.body}'};
      }
      return {'error': 'Error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      debugPrint('Error adding photo: $e');
      return {'error': e.toString()};
    }
  }

  /// Uploads or updates a video
  static Future<Map<String, dynamic>> uploadVideo(String videoPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      var request = http.MultipartRequest(
        'POST', // Both POST and UPDATE use the same endpoint, so POST is typical for file uploads or we can use PATCH if backend prefers. But POST is universally accepted for Multipart. Let's use POST. The user said POST/UPDATE.
        Uri.parse('$baseUrl/user/profile/video'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'video', // Assuming the field name is 'video'
          videoPath,
          contentType: MediaType('video', 'mp4'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
          return {'error': null, 'data': decoded}; // Success
        }
        return {'error': decoded['message'] ?? 'Failed: ${response.body}'};
      }
      return {'error': 'Error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      debugPrint('Error uploading video: $e');
      return {'error': e.toString()};
    }
  }

  /// Updates a specific photo on the server.
  static Future<String?> updateSpecificPhoto(
    String photoId,
    String imagePath,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      var request = http.MultipartRequest(
        'PATCH', // The backend provided PATCH for this endpoint
        Uri.parse('$baseUrl/user/profile/photos/$photoId'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // Singular field based on 400 error
          imagePath,
          filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
          return null; // Success
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error updating photo: $e');
      return e.toString();
    }
  }

  /// Deletes a specific photo from the server.
  static Future<String?> deletePhoto(String photoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.delete(
        Uri.parse('$baseUrl/user/profile/photos/$photoId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Delete Photo Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
          return null;
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error deleting photo: $e');
      return e.toString();
    }
  }

  // Updates the user's bio
  static Future<String?> updateBio(String bioText) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse(
          '$baseUrl/user/edit-profile/bio',
        ), // updated to new URL from backend team
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"bio": bioText}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
          return null; // Success
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error updating bio: $e');
      return e.toString();
    }
  }

  // Fetches Networking Intents
  static Future<List<Map<String, dynamic>>?> getNetworkingIntents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/question/fetch?category=DATING&screen=NETWORKING_INTENT'),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        debugPrint('GET NETWORKING INTENTS RESPONSE: ${response.body}');
        if (decoded['success'] == true && decoded['data'] != null) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching networking intents: $e');
      return null;
    }
  }

  // Updates answers (e.g. for VIP Networking Intent, Favorites, etc.)
  static Future<bool> updateAnswers({
    required String questionKey,
    required List<String> optionIds,
    String? description,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final body = {
        "questionKey": questionKey,
        "optionIds": optionIds,
        if (description != null && description.isNotEmpty) "description": description,
      };

      final response = await http.patch(
        Uri.parse('$baseUrl/user/edit-profile/answers'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint('Update Answers Status: ${response.statusCode}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      debugPrint('Failed to update answers: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error updating answers: $e');
      return false;
    }
  }

  // Updates the user's looking-for intention
  static Future<String?> updateIntention(String optionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/looking-for'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"optionId": optionId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
          return null; // Success
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error updating intention: $e');
      return e.toString();
    }
  }

  // Updates Who You Are Seeing (Interested In & Sexual Orientation)
  static Future<String?> updateInterestedIn(
    String interestedIn,
    String sexualOrientation,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/interested-in'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "interested_in": interestedIn,
          "sexual_orientation": sexualOrientation,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
          return null; // Success
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error updating interested-in: $e');
      return e.toString();
    }
  }

  // Updates user profile answers for Lifestyle, Interests, Networking (PATCH)
  static Future<String?> updateProfileAnswer({
    required String questionKey,
    required List<String> optionIds,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/edit-profile/answers'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"questionKey": questionKey, "optionIds": optionIds}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
          return null; // Success
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error updating profile answer: $e');
      return e.toString();
    }
  }

  // Updates Prompts
  static Future<Map<String, dynamic>> updatePrompt({
    required String categoryId,
    required String promptId,
    required String answer,
    required int displayOrder,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/edit-profile/prompts'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "categoryId": categoryId,
          "promptId": promptId,
          "answer": answer,
          "displayOrder": displayOrder,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
          return {'error': null};
        }
        return {'error': decoded['message'] ?? 'Failed: ${response.body}'};
      }
      return {'error': 'Error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      debugPrint('Error updating prompt: $e');
      return {'error': 'Network error occurred'};
    }
  }

  static Future<Map<String, dynamic>> deletePrompt(String promptId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/user/edit-profile/prompt/$promptId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {'error': 'Failed: ${response.statusCode} - ${response.body}'};
      }
    } catch (e) {
      debugPrint('Error deleting prompt: $e');
      return {'error': 'Network error occurred'};
    }
  }

  // Fetches the user's full profile details
  static Future<Map<String, dynamic>> getProfileDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile/details'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return {'error': null, 'data': decoded['data']};
        }
        return {'error': decoded['message'] ?? 'Failed to parse profile data'};
      }
      return {'error': 'Error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      debugPrint('Error fetching profile details: $e');
      return {'error': e.toString()};
    }
  }

  // Updates basic details
  static Future<String?> updateBasicDetails(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/edit-profile/basic-info'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
          return null; // Success
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error updating basic details: $e');
      return e.toString();
    }
  }

  // Updates user's career and ambition details
  static Future<String?> updateCareer(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/edit-profile/education-work'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
          return null; // Success
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error updating career: $e');
      return e.toString();
    }
  }

  // Updates Religion
  static Future<String?> updateReligion(
    int religionId,
    int? communityId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final body = <String, dynamic>{'religionId': religionId};
      if (communityId != null) body['communityId'] = communityId;

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/religion'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true || decoded['status'] == 200) {
          return null;
        }
        return decoded['message'] ?? 'Failed: ${response.body}';
      }
      return 'Error ${response.statusCode}: ${response.body}';
    } catch (e) {
      debugPrint('Error updating religion: $e');
      return e.toString();
    }
  }

  static Future<Map<String, dynamic>> getReligions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/religion/get'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return {'error': null, 'data': decoded['data']};
        }
        return {'error': 'Failed to parse religion data'};
      }
      return {'error': 'Error ${response.statusCode}: ${response.body}'};
    } catch (e) {
      debugPrint('Error fetching religions: $e');
      return {'error': e.toString()};
    }
  }

  // Fetches languages
  static Future<List<dynamic>> getLanguages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/languages/get'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching languages: $e');
      return [];
    }
  }
}
