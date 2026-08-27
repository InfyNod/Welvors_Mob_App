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
}
