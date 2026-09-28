import 'package:flutter/material.dart';

enum MembershipTier { premiumPlus, vip, elite }

class MembershipPlanModel {
  final String id;
  final MembershipTier tier;
  final String name;
  final String badge;
  final String? badgeLabel; // From API
  final String emoji;
  final String description;
  final String monthlyPrice;
  final String yearlyPrice;
  final String yearlySaving;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final List<PlanDuration> durations;
  final WeeklyBenefits weeklyBenefits;
  final List<PlanSection> sections;
  final List<dynamic>? rawFeatures; // From API

  const MembershipPlanModel({
    this.id = '',
    required this.tier,
    required this.name,
    required this.badge,
    this.badgeLabel,
    required this.emoji,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.yearlySaving,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.durations,
    required this.weeklyBenefits,
    required this.sections,
    this.rawFeatures,
  });
}

class PlanDuration {
  final String id;
  final int months;
  final String title;
  final String price;
  final String perMonth;
  final String saving;
  final bool selected;
  final int originalPrice;

  const PlanDuration({
    this.id = '',
    this.months = 1,
    required this.title,
    required this.price,
    required this.perMonth,
    this.saving = '',
    this.selected = false,
    this.originalPrice = 0,
  });
}

class WeeklyBenefitItem {
  final String emoji;
  final String value;
  final String subtitle;

  const WeeklyBenefitItem({
    required this.emoji,
    required this.value,
    required this.subtitle,
  });
}

class WeeklyBenefits {
  final List<WeeklyBenefitItem> items;

  const WeeklyBenefits({
    this.items = const [],
  });
}

class PlanSection {
  final String title;
  final String emoji;
  final List<PlanFeature> features;

  const PlanSection({
    required this.title,
    required this.emoji,
    required this.features,
  });
}

class PlanFeature {
  final String title;
  final String subtitle;

  const PlanFeature({required this.title, this.subtitle = ''});
}
