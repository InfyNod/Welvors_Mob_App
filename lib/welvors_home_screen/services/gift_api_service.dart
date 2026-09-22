import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:velvors/config/env_config.dart';

import 'logger_service.dart' show AppLogger;

class GiftCategory {
  final int id;
  final String name;

  const GiftCategory({required this.id, required this.name});

  factory GiftCategory.fromJson(Map<String, dynamic> json) {
    return GiftCategory(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
    );
  }
}

class ApiGift {
  final int id;
  final int categoryId;
  final String image;
  final String name;
  final int coinCost;
  final String triggerLine;
  final String receiverLine;
  final bool isLive;

  const ApiGift({
    required this.id,
    required this.categoryId,
    required this.image,
    required this.name,
    required this.coinCost,
    required this.triggerLine,
    required this.receiverLine,
    required this.isLive,
  });

  factory ApiGift.fromJson(Map<String, dynamic> json) {
    return ApiGift(
      id: (json['id'] as num).toInt(),
      categoryId: (json['categoryId'] as num?)?.toInt() ??
          ((json['category']?['id'] as num?)?.toInt() ?? 0),
      image: (json['image'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      coinCost: (json['coinCost'] as num?)?.toInt() ?? 0,
      triggerLine: (json['triggerLine'] ?? '').toString(),
      receiverLine: (json['receiverLine'] ?? '').toString(),
      isLive: json['isLive'] == true,
    );
  }
}

class GiftApiService {
  static String get baseUrl => EnvConfig.apiBaseUrl;

  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token')?.trim();
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
    };
  }

  static Future<List<GiftCategory>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/revenue/gift-category/list'),
      headers: await _headers(),
    );

    AppLogger.apiResponse(
      'GiftApiService',
      statusCode: response.statusCode,
      body: response.body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gift categories failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Unable to load gift categories');
    }

    final data = (decoded['data'] as List? ?? const []);
    return data
        .whereType<Map>()
        .map((e) => GiftCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<List<ApiGift>> fetchGifts({int? categoryId}) async {
    final uri = Uri.parse('$baseUrl/revenue/gift/list').replace(
      queryParameters: categoryId == null
          ? null
          : {'categoryId': categoryId.toString()},
    );

    final response = await http.get(uri, headers: await _headers());
    AppLogger.apiResponse(
      'GiftApiService',
      statusCode: response.statusCode,
      body: response.body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gift list failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Unable to load gifts');
    }

    final data = (decoded['data'] as List? ?? const []);
    return data
        .whereType<Map>()
        .map((e) => ApiGift.fromJson(Map<String, dynamic>.from(e)))
        .where((gift) => gift.isLive)
        .toList();
  }

  /// Loads the categories and all live gifts. The API currently may return
  /// the full gift list even when categoryId is supplied, so the result is
  /// grouped on the client by categoryId to keep the UI correct either way.
  static Future<GiftCatalog> fetchCatalog() async {
    final categories = await fetchCategories();
    final responses = await Future.wait(
      categories.map((category) => fetchGifts(categoryId: category.id)),
    );

    final byId = <int, ApiGift>{};
    for (final list in responses) {
      for (final gift in list) {
        byId[gift.id] = gift;
      }
    }

    return GiftCatalog(categories: categories, gifts: byId.values.toList());
  }
}

class GiftCatalog {
  final List<GiftCategory> categories;
  final List<ApiGift> gifts;

  const GiftCatalog({required this.categories, required this.gifts});

  List<ApiGift> giftsForCategory(int categoryId) {
    return gifts.where((gift) => gift.categoryId == categoryId).toList();
  }
}
