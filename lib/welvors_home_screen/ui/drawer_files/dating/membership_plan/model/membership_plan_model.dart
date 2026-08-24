import 'package:flutter/material.dart';

enum MembershipTier { premiumPlus, vip, elite }

class MembershipPlanModel {
  final MembershipTier tier;
  final String name;
  final String badge;
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

  const MembershipPlanModel({
    required this.tier,
    required this.name,
    required this.badge,
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
  });
}

class PlanDuration {
  final String title;
  final String price;
  final String perMonth;
  final String saving;
  final bool selected;

  const PlanDuration({
    required this.title,
    required this.price,
    required this.perMonth,
    this.saving = '',
    this.selected = false,
  });
}

class WeeklyBenefits {
  final String datePlans;
  final String boosts;
  final String compliments;
  final String coins;

  const WeeklyBenefits({
    required this.datePlans,
    required this.boosts,
    required this.compliments,
    required this.coins,
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
