import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvors/config/env_config.dart';
import 'package:velvors/welvors_home_screen/services/logger_service.dart';

/// Model representing a new match item.
class NewMatchItem {
  final String id;
  final String userId;
  final String name;
  final int age;
  final String image;
  final String type;
  final String content;
  final String createdAt;
  final String badgeText;
  final bool isGiftBadge;
  final String matchScore;
  final String trustScore;

  const NewMatchItem({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.image,
    required this.type,
    required this.content,
    required this.createdAt,
    required this.badgeText,
    required this.isGiftBadge,
    required this.matchScore,
    required this.trustScore,
  });

  factory NewMatchItem.fromJson(Map<String, dynamic> json) {
    // Extract nested sender or user objects if present
    final sender = json['sender'] is Map
        ? Map<String, dynamic>.from(json['sender'] as Map)
        : (json['user'] is Map
            ? Map<String, dynamic>.from(json['user'] as Map)
            : const <String, dynamic>{});

    final String userId = (sender['id'] ??
            sender['_id'] ??
            sender['userId'] ??
            json['userId'] ??
            json['id'] ??
            json['_id'] ??
            '')
        .toString();

    final String name = (sender['name'] ??
            sender['fullName'] ??
            json['name'] ??
            'Unknown')
        .toString();

    final dynamic rawAge = sender['age'] ?? json['age'];
    final int age = rawAge is num
        ? rawAge.toInt()
        : int.tryParse(rawAge?.toString() ?? '') ?? 0;

    // Photo extraction
    String image = (sender['photo'] ??
            sender['profilePhoto'] ??
            sender['image'] ??
            json['photo'] ??
            json['image'] ??
            '')
        .toString();

    if (image.isEmpty && sender['photos'] is List && (sender['photos'] as List).isNotEmpty) {
      image = (sender['photos'] as List).first.toString();
    } else if (image.isEmpty && json['photos'] is List && (json['photos'] as List).isNotEmpty) {
      image = (json['photos'] as List).first.toString();
    }

    final String type = (json['type'] ?? 'MATCH').toString().toUpperCase();
    final String content = (json['content'] ?? json['message'] ?? '').toString();
    final String createdAt = (json['createdAt'] ?? '').toString();

    // Determine badge and style
    String badgeText = 'NEW';
    bool isGiftBadge = false;

    if (type.contains('GIFT')) {
      badgeText = '🎁';
      isGiftBadge = true;
    } else if (type.contains('ROSE')) {
      badgeText = '🌹';
      isGiftBadge = false;
    } else if (type.contains('COMPLIMENT') || type.contains('MESSAGE')) {
      badgeText = '💌';
      isGiftBadge = false;
    } else {
      badgeText = 'NEW';
      isGiftBadge = false;
    }

    // Match & trust scores
    final matchScore = (json['matchScore'] ??
            json['matchPercentage'] ??
            json['match'] ??
            sender['matchScore'] ??
            '')
        .toString();

    final trustScore = (json['trustScore'] ??
            json['trust'] ??
            sender['trustScore'] ??
            '')
        .toString();

    return NewMatchItem(
      id: (json['id'] ?? json['messageId'] ?? userId).toString(),
      userId: userId,
      name: name,
      age: age,
      image: image,
      type: type,
      content: content,
      createdAt: createdAt,
      badgeText: badgeText,
      isGiftBadge: isGiftBadge,
      matchScore: matchScore.isNotEmpty ? matchScore.replaceAll('%', '') : '',
      trustScore: trustScore.isNotEmpty ? trustScore.replaceAll('%', '') : '',
    );
  }
}

/// Paginated result of new matches.
class NewMatchesPageResult {
  final List<NewMatchItem> matches;
  final bool hasMore;
  final int total;
  final int currentPage;

  const NewMatchesPageResult({
    required this.matches,
    required this.hasMore,
    required this.total,
    required this.currentPage,
  });
}

class NewMatchesService {
  NewMatchesService._();
  static final NewMatchesService instance = NewMatchesService._();

  static const String endpointPath = '/user/matches/new';

  /// Primary API URL for new matches: {EnvConfig.apiBaseUrl}/user/matches/new
  String get _baseUrl => '${EnvConfig.apiBaseUrl}$endpointPath';

  /// Fetches new matches with pagination support (page, limit).
  Future<NewMatchesPageResult> getNewMatches({
    int page = 1,
    int limit = 20,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final rawToken = prefs.getString('auth_token')?.trim() ?? '';
    final token = rawToken.toLowerCase().startsWith('bearer ')
        ? rawToken
        : 'Bearer $rawToken';

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });

    AppLogger.i('NewMatchesService', '🚀 REQUEST: GET $uri with auth=${rawToken.isNotEmpty}');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Accept-Language': 'en-US,en;q=0.9',
        if (rawToken.isNotEmpty) 'Authorization': token,
      },
    );

    AppLogger.i(
      'NewMatchesService',
      '📦 RESPONSE (${response.statusCode}): ${response.body}',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String errorMessage = 'Unable to load new matches (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          errorMessage = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
      final msg = decoded is Map ? decoded['message']?.toString() : null;
      throw Exception(msg ?? 'New matches API returned success=false');
    }

    // Extract list of items
    dynamic rawData = decoded['data'];
    List<dynamic> itemsList = [];

    if (rawData is List) {
      itemsList = rawData;
    } else if (rawData is Map) {
      if (rawData['matches'] is List) {
        itemsList = rawData['matches'] as List;
      } else if (rawData['data'] is List) {
        itemsList = rawData['data'] as List;
      } else if (rawData['users'] is List) {
        itemsList = rawData['users'] as List;
      }
    }

    final List<NewMatchItem> parsed = itemsList
        .whereType<Map>()
        .map((item) => NewMatchItem.fromJson(Map<String, dynamic>.from(item)))
        .where((item) => item.userId.isNotEmpty)
        .toList();

    // Deduplicate by userId while preserving order
    final uniqueMap = <String, NewMatchItem>{};
    for (final item in parsed) {
      if (!uniqueMap.containsKey(item.userId)) {
        uniqueMap[item.userId] = item;
      }
    }
    final uniqueList = uniqueMap.values.toList();

    // Determine pagination status
    bool hasMore = false;
    int total = uniqueList.length;

    if (decoded['pagination'] is Map) {
      final pag = decoded['pagination'] as Map;
      final totalPages = int.tryParse(pag['totalPages']?.toString() ?? '') ?? 1;
      final totalCount = int.tryParse(pag['total']?.toString() ?? '') ?? uniqueList.length;
      total = totalCount;
      hasMore = page < totalPages;
    } else if (decoded['meta'] is Map) {
      final meta = decoded['meta'] as Map;
      final totalPages = int.tryParse(meta['totalPages']?.toString() ?? '') ?? 1;
      hasMore = page < totalPages;
    } else {
      // If no pagination metadata returned, judge by whether page returned a full batch
      hasMore = parsed.length >= limit;
    }

    return NewMatchesPageResult(
      matches: uniqueList,
      hasMore: hasMore,
      total: total,
      currentPage: page,
    );
  }
}
