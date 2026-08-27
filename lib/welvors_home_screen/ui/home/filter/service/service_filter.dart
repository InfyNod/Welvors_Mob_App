import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServiceFilter {
  static const String baseUrl = 'https://api.welvors.com/api';
  // TODO: Replace with dynamic token from secure storage or auth provider when available
  static const String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI0NmQzZjA5Ny0yODI1LTRhNDEtYWRjNS04NzQ3ZTNiMDdmMmIiLCJpYXQiOjE3ODY3MDI5MDEsImV4cCI6MTc4OTI5NDkwMX0.boqFsoOvwHgOk_iC-ijAnXv1uFH75Gx5uAdFi7FSpvs';

  /// Fetches options for the "Looking For" filter
  static Future<Map<String, dynamic>?> fetchLookingForOptions() async {
    try {
      final url = Uri.parse('$baseUrl/onboarding/intention/get');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final dataArray = decoded['data'] as List;
          if (dataArray.isNotEmpty) {
            final category = dataArray[0];
            final title = category['title']?.toString().replaceAll('"', '') ?? "What are you here for?";
            final subtitle = category['description']?.toString().replaceAll('"', '') ?? "However you love, you belong here";
            final optionsList = category['options'] as List;
            
            final List<Color> bgColors = [
              const Color(0xFFFCE9EE), // Soft pink
              const Color(0xFFE8F0FE), // Soft blue
              const Color(0xFFFFF9E6), // Soft gold
              const Color(0xFFE6F4EA), // Soft green
              const Color(0xFFFAF1FD), // Light purple
            ];
            final List<String> icons = ['💝', '💍', '✨', '🤝', '🥂', '👀'];
            
            final List<Map<String, dynamic>> mappedOptions = [];
            for (int i = 0; i < optionsList.length; i++) {
              final opt = optionsList[i];
              mappedOptions.add({
                'id': opt['id'],
                'title': opt['option'],
                'subtitle': opt['optDescription'],
                'icon': icons[i % icons.length],
                'iconBgColor': bgColors[i % bgColors.length],
              });
            }
            
            return {
              'title': title,
              'subtitle': subtitle,
              'options': mappedOptions,
            };
          }
        }
      }
    } catch (e) {
      debugPrint('====== [FILTER API ERROR] ======');
      debugPrint(e.toString());
    }
    return null;
  }

  /// Fetches options for the "Languages" filter
  static Future<List<dynamic>?> fetchLanguages() async {
    try {
      final url = Uri.parse('$baseUrl/admin/languages/get-All');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });
      
      debugPrint('====== [LANGUAGES API RESPONSE] ======');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return decoded['data'] as List;
        }
      }
    } catch (e) {
      debugPrint('====== [LANGUAGES API ERROR] ======');
      debugPrint(e.toString());
    }
    return null;
  }

  /// Fetches options for the "Lifestyle" filter
  static Future<List<dynamic>?> fetchLifestyleOptions() async {
    try {
      final url = Uri.parse('$baseUrl/question/fetch?category=DATING&screen=LIFESTYLE');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });
      
      debugPrint('====== [LIFESTYLE API RESPONSE] ======');
      debugPrint('STATUS: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return decoded['data'] as List;
        }
      }
    } catch (e) {
      debugPrint('====== [LIFESTYLE API ERROR] ======');
      debugPrint(e.toString());
    }
    return null;
  }

  /// Fetches options for the "Religion" filter
  static Future<List<dynamic>?> fetchReligionOptions() async {
    try {
      final url = Uri.parse('$baseUrl/religion/get');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });
      
      debugPrint('====== [RELIGION API RESPONSE] ======');
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          return decoded['data'] as List;
        }
      }
    } catch (e) {
      debugPrint('====== [RELIGION API ERROR] ======');
      debugPrint(e.toString());
    }
    return null;
  }

  /// Fetches options for the "Profession" filter
  static Future<List<dynamic>?> fetchProfessionOptions() async {
    try {
      final url = Uri.parse('$baseUrl/onboarding/professions/get');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });
      
      debugPrint('====== [PROFESSION API RESPONSE] ======');
      debugPrint('STATUS: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['professions'] != null) {
          return decoded['professions'] as List; // It's usually 'data' or 'professions'
        } else if (decoded['success'] == true && decoded['data'] != null) {
          return decoded['data'] as List;
        }
      }
    } catch (e) {
      debugPrint('====== [PROFESSION API ERROR] ======');
      debugPrint(e.toString());
    }
    return null;
  }

  /// Fetches options for the "Family Income" filter
  static Future<List<Map<String, dynamic>>> fetchFamilyIncomes() async {
    try {
      final url = Uri.parse('$baseUrl/admin/family-incomes/get-all');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final dataArray = decoded['data'] as List;
          return List<Map<String, dynamic>>.from(dataArray);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching family incomes: $e');
      return [];
    }
  }

  /// Fetches options for the "Networking Intent" filter
  static Future<List<Map<String, dynamic>>> fetchNetworkingIntentOptions() async {
    try {
      final url = Uri.parse('$baseUrl/question/fetch?category=DATING&screen=NETWORKING_INTENT');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final dataArray = decoded['data'] as List;
          if (dataArray.isNotEmpty) {
            final optionsList = dataArray[0]['options'] as List;
            return List<Map<String, dynamic>>.from(optionsList);
          }
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching networking intent: $e');
      return [];
    }
  }

  /// Fetches options for the "Ambition" filter
  static Future<List<Map<String, dynamic>>> fetchAmbitionOptions() async {
    try {
      final url = Uri.parse('$baseUrl/admin/ambitions/get');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final dataArray = decoded['data'] as List;
          return List<Map<String, dynamic>>.from(dataArray);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching ambition options: $e');
      return [];
    }
  }
}
