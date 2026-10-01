import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:velvors/welvors_home_screen/services/token_helper.dart';

import '../model/membership_plan_model.dart';

class MembershipPlanRepository {
  Future<List<MembershipPlanModel>> fetchPlans() async {
    List<dynamic> apiPackages = [];
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.get(
        Uri.parse('https://api.welvors.com/api/package/get/cards'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          apiPackages = data['data'] ?? [];
        }
      }
    } catch (e) {
      print('Error fetching membership plans: $e');
    }

    // Default hardcoded base models
    final defaultPremium = MembershipPlanModel(
      id: '',
      tier: MembershipTier.premiumPlus,
      name: 'Premium+',
      badge: 'PREMIUM PLUS',
      emoji: '🔥',
      description: 'Find better matches. Date safer. Connect faster.',
      monthlyPrice: '₹499',
      yearlyPrice: '₹3,999/year',
      yearlySaving: 'save 33%',
      primaryColor: const Color(0xFFD63B5F),
      secondaryColor: const Color(0xFFF0516A),
      textColor: Colors.white,
      durations: [],
      weeklyBenefits: WeeklyBenefits(items: []),
      sections: [],
    );

    final defaultVip = MembershipPlanModel(
      id: '',
      tier: MembershipTier.vip,
      name: 'VIP',
      badge: 'VIP MEMBERSHIP',
      emoji: '👑',
      description:
          'Exclusive access for premium singles seeking elevated connections.',
      monthlyPrice: '₹1,999',
      yearlyPrice: '₹14,999/year',
      yearlySaving: 'save 37%',
      primaryColor: const Color(0xFFE0AA3E),
      secondaryColor: const Color(0xFFA67620),
      textColor: Colors.white,
      durations: [],
      weeklyBenefits: WeeklyBenefits(items: []),
      sections: [],
    );

    final defaultElite = MembershipPlanModel(
      id: '',
      tier: MembershipTier.elite,
      name: 'VIP Elite',
      badge: 'PRIVATE MEMBERSHIP',
      emoji: '💠',
      description: 'Invitation only. Only 100 members accepted per city.',
      monthlyPrice: '₹49,999',
      yearlyPrice: '₹49,999/year',
      yearlySaving: '',
      primaryColor: const Color(0xFF2C2C2C),
      secondaryColor: const Color(0xFF111111),
      textColor: Colors.white,
      durations: [],
      weeklyBenefits: WeeklyBenefits(items: []),
      sections: [],
    );

    // Now map API data to our models
    MembershipPlanModel mergedPremium = defaultPremium;
    MembershipPlanModel mergedVip = defaultVip;
    MembershipPlanModel mergedElite = defaultElite;

    for (var pkg in apiPackages) {
      final slug = pkg['slug']?.toString().toLowerCase() ?? '';
      final id = pkg['id']?.toString() ?? '';
      final price = pkg['price']?.toString() ?? '';
      final rawName = pkg['name']?.toString() ?? '';
      final name = rawName.replaceAll('_', ' ');
      final badgeLabel = pkg['badgeLabel']?.toString();
      final tagline = pkg['tagline']?.toString();
      final features = pkg['features'] as List<dynamic>?;
      final limits = pkg['limits'] as List<dynamic>?;

      List<PlanDuration>? dynamicDurations;
      List<dynamic>? dynamicLimits;
      if (id.isNotEmpty) {
        final details = await _fetchPackageDetails(id);
        if (details != null) {
          dynamicDurations = details['durations'] as List<PlanDuration>?;
          dynamicLimits = details['limits'] as List<dynamic>?;
        }
      }

      final limitsToParse = dynamicLimits ?? limits;

      if (slug == 'premium') {
        final dynamicBenefits = _parseWeeklyBenefits(
          limitsToParse,
          defaultPremium.weeklyBenefits,
        );
        final dynamicSections = _parseSections(limitsToParse);
        mergedPremium = _mergeWithApi(
          defaultPremium,
          id,
          name,
          price,
          features,
          badgeLabel,
          dynamicDurations,
          tagline,
          dynamicBenefits,
          dynamicSections,
        );
      } else if (slug == 'vip') {
        final dynamicBenefits = _parseWeeklyBenefits(
          limitsToParse,
          defaultVip.weeklyBenefits,
        );
        final dynamicSections = _parseSections(limitsToParse);
        mergedVip = _mergeWithApi(
          defaultVip,
          id,
          name,
          price,
          features,
          badgeLabel,
          dynamicDurations,
          tagline,
          dynamicBenefits,
          dynamicSections,
        );
      } else if (slug == 'vip-elite' ||
          slug == 'vip_elite' ||
          slug == 'elite') {
        final dynamicBenefits = _parseWeeklyBenefits(
          limitsToParse,
          defaultElite.weeklyBenefits,
        );
        final dynamicSections = _parseSections(limitsToParse);
        mergedElite = _mergeWithApi(
          defaultElite,
          id,
          name,
          price,
          features,
          badgeLabel,
          dynamicDurations,
          tagline,
          dynamicBenefits,
          dynamicSections,
        );
      }
    }

    return [mergedPremium, mergedVip, mergedElite];
  }

  Future<Map<String, dynamic>?> _fetchPackageDetails(String id) async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.get(
        Uri.parse('https://api.welvors.com/api/package/get/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final packageData = data['data'];

          List<PlanDuration> durations = [];
          if (packageData['prices'] != null) {
            final prices = packageData['prices'] as List<dynamic>;
            for (var p in prices) {
              final pId = p['id']?.toString() ?? '';
              final months = p['months'] as int? ?? 1;
              final price = p['price'] as int? ?? 0;
              final originalPrice = p['originalPrice'] as int? ?? price;
              final discountPercent = p['discountPercent'] as int? ?? 0;
              final isHighlighted = p['isHighlighted'] as bool? ?? false;
              final active = p['active'] as bool? ?? true;

              if (!active) continue;

              final title = months == 1 ? '1 MONTH' : '$months MONTHS';
              final perMonthPrice = (price / months).round();

              durations.add(
                PlanDuration(
                  id: pId,
                  months: months,
                  originalPrice: originalPrice,
                  title: title,
                  price: '₹$price',
                  perMonth: '₹$perMonthPrice/mo',
                  saving: discountPercent > 0 ? 'SAVE $discountPercent%' : '',
                  selected: isHighlighted,
                ),
              );
            }
            // Sort by months (1, 3, 6, 12)
            durations.sort((a, b) => a.months.compareTo(b.months));
          }

          return {
            'durations': durations.isNotEmpty ? durations : null,
            'limits': packageData['limits'] as List<dynamic>?,
          };
        }
      }
    } catch (e) {
      print('Error fetching package details for $id: $e');
    }
    return null;
  }

  List<PlanSection> _parseSections(List<dynamic>? limits) {
    if (limits == null || limits.isEmpty) return [];

    final Map<String, (String, String)> categoryMap = {
      'MATCH_DISCOVERY': ('MATCH & DISCOVERY', '❤️'),
      'STATUS_BADGES': ('STATUS & BADGES', '🏆'),
      'NETWORKING_GROWTH': ('NETWORKING & GROWTH', '💼'),
      'PERKS': ('PERKS & REWARDS', '🎁'),
      'CHAT': ('CHAT & MESSAGING', '💬'),
      'PRIVACY': ('PRIVACY', '🔒'),
      'TRUST': ('TRUST & VERIFICATION', '🛡️'),
      'REAL_LIFE_EVENTS': ('REAL-LIFE & EVENTS', '🎉'),
      'PREMIUM_EXPERIENCES': ('PREMIUM EXPERIENCES', '✨'),
      'GLOBAL_EXPERIENCES': ('GLOBAL EXPERIENCES', '🌎'),
      'EXECUTIVE_NETWORK': ('EXECUTIVE NETWORK', '🤝'),
      'WHITE_GLOVE_EXPERIENCES': ('WHITE-GLOVE EXPERIENCES', '🎩'),
      'MAXIMUM_PRIVACY': ('MAXIMUM PRIVACY', '🕵️'),
      'ELITE_STATUS': ('ELITE STATUS', '💎'),
      'CURATED_ELITE_MATCHING': ('ELITE MATCHING', '🎯'),
    };

    final Map<String, List<PlanFeature>> groupedFeatures = {};

    for (var l in limits) {
      if (l['enabled'] != true) continue;
      final feature = l['feature'];
      if (feature == null) continue;

      final category = feature['category']?.toString() ?? 'OTHER';
      final title = feature['title']?.toString() ?? '';
      final subtitle = feature['description']?.toString() ?? '';

      if (!groupedFeatures.containsKey(category)) {
        groupedFeatures[category] = [];
      }
      groupedFeatures[category]!.add(
        PlanFeature(title: title, subtitle: subtitle),
      );
    }

    List<PlanSection> parsedSections = [];
    for (var entry in groupedFeatures.entries) {
      final category = entry.key;
      final mapping =
          categoryMap[category] ?? (category.replaceAll('_', ' '), '✨');
      parsedSections.add(
        PlanSection(
          title: mapping.$1,
          emoji: mapping.$2,
          features: entry.value,
        ),
      );
    }

    return parsedSections;
  }

  WeeklyBenefits _parseWeeklyBenefits(
    List<dynamic>? limits,
    WeeklyBenefits baseBenefits,
  ) {
    if (limits == null || limits.isEmpty) return baseBenefits;

    // Define which codes we want to show and their mappings
    final targetCodes = {
      'WEEKLY_DATE_PLANS': ('🗓️', 'Date plans / wk'),
      'WEEKLY_BOOSTS': ('🚀', 'Boosts / wk'),
      'WEEKLY_COMPLIMENTS': ('💝', 'Compliments / wk'),
      'WELCOME_COINS': ('🪙', 'Coins / one-time'),
      'ROSES': ('🌟', 'Roses / wk'),
      'REWINDS': ('↩️', 'Rewinds / day'),
      'UNLIMITED_LIKES': ('❤️', 'Likes / one-time'),
    };

    List<WeeklyBenefitItem> parsedItems = [];

    for (var l in limits) {
      if (l['enabled'] != true) continue;

      final feature = l['feature'];
      if (feature == null) continue;

      final code = feature['code']?.toString() ?? '';

      // Only include if it's one of our target consumable features
      if (targetCodes.containsKey(code)) {
        final unlimited = l['unlimited'] == true;
        final limitValue = l['limit']?.toString() ?? '0';
        final displayValue = unlimited ? '∞' : limitValue;

        final mapping = targetCodes[code]!;
        parsedItems.add(
          WeeklyBenefitItem(
            emoji: mapping.$1,
            value: displayValue,
            subtitle: mapping.$2,
          ),
        );
      }
    }

    if (parsedItems.isEmpty) return baseBenefits;

    return WeeklyBenefits(items: parsedItems);
  }

  MembershipPlanModel _mergeWithApi(
    MembershipPlanModel base,
    String id,
    String name,
    String price,
    List<dynamic>? features,
    String? badgeLabel,
    List<PlanDuration>? dynamicDurations,
    String? tagline,
    WeeklyBenefits? dynamicBenefits,
    List<PlanSection>? dynamicSections,
  ) {
    // We update the monthlyPrice and ID from the API.
    final newPriceStr = price.isNotEmpty ? '₹$price' : base.monthlyPrice;

    return MembershipPlanModel(
      id: id.isNotEmpty ? id : base.id,
      tier: base.tier,
      name: name.isNotEmpty ? name : base.name,
      badge: base.badge,
      badgeLabel: badgeLabel,
      emoji: base.emoji,
      description: tagline != null && tagline.isNotEmpty
          ? tagline
          : base.description,
      monthlyPrice: newPriceStr,
      yearlyPrice: base.yearlyPrice,
      yearlySaving: base.yearlySaving,
      primaryColor: base.primaryColor,
      secondaryColor: base.secondaryColor,
      textColor: base.textColor,
      durations: dynamicDurations ?? base.durations,
      weeklyBenefits: dynamicBenefits ?? base.weeklyBenefits,
      sections: dynamicSections != null && dynamicSections.isNotEmpty
          ? dynamicSections
          : base.sections,
      rawFeatures: features,
    );
  }

  Future<Map<String, dynamic>> purchasePackage(String priceId) async {
    try {
      final token = await TokenHelper.getToken() ?? "";
      final response = await http.post(
        Uri.parse('https://api.welvors.com/api/user/package/wallet/purchase'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'priceId': priceId}),
      );

      final data = json.decode(response.body);
      return data;
    } catch (e) {
      print('Error purchasing package: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
