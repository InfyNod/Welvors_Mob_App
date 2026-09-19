import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'shared_item_model.dart';

class SharedItemRepository {
  static const String _baseUrl =
      'https://api.welvors.com/api/user/chat/shareditem';

  Future<SharedItemsBundle> getSharedItems(String conversationId) async {
    if (conversationId.trim().isEmpty) {
      throw Exception('Conversation ID is missing');
    }

    debugPrint('📦 SHARED ITEMS conversationId: $conversationId');

    final results = await Future.wait([
      _getItems(conversationId: conversationId, type: 'MEDIA'),
      _getItems(conversationId: conversationId, type: 'LINKS'),
      _getItems(conversationId: conversationId, type: 'DOCUMENTS'),
    ]);

    return SharedItemsBundle(
      media: results[0],
      documents: results[1],
      links: results[2],
    );
  }

  Future<List<SharedItem>> _getItems({
    required String conversationId,
    required String type,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/${Uri.encodeComponent(conversationId)}'
      '?type=$type',
    );

    debugPrint('📡 SHARED ITEM API');
    debugPrint('➡️ TYPE: $type');
    debugPrint('➡️ URL: $uri');

    final headers = await _headers();

    final response = await http.get(uri, headers: headers);

    debugPrint('⬅️ STATUS [$type]: ${response.statusCode}');

    debugPrint('⬅️ RESPONSE [$type]: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unable to load $type (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map) {
      throw Exception('Invalid $type API response');
    }

    if (decoded['success'] != true) {
      throw Exception(decoded['message']?.toString() ?? 'Unable to load $type');
    }

    final rawData = decoded['data'];

    if (rawData is! List) {
      return [];
    }

    return rawData
        .whereType<Map>()
        .map((item) => SharedItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token')?.trim() ?? '';

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token.isNotEmpty)
        'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
    };
  }
}
