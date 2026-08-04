import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileApiService {
  // Update this baseUrl if it differs for your environment
  static const String baseUrl = 'https://dating-app-backend-plum.vercel.app/api';

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

  /// Updates a specific photo on the server.
  static Future<String?> updateSpecificPhoto(String photoId, String imagePath) async {
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

  // Updates the user's bio
  static Future<String?> updateBio(String bioText) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/edit-profile/bio'), // updated to new URL from backend team
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

  // Updates the user's looking-for intention
  static Future<String?> updateIntention(String intentionId, String title, String subtitle) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.patch(
        Uri.parse('$baseUrl/user/profile/looking-for'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "intentionId": intentionId,
          "title": title,
          "subtitle": subtitle,
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
      debugPrint('Error updating intention: $e');
      return e.toString();
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
        Uri.parse('$baseUrl/user/profile/basic-info'),
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
}
