import 'package:flutter/material.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';

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
        primaryColor: AppColors.pink,
        secondaryColor: AppColors.pinkDeep,
        textColor: Colors.white,
        durations: [
          PlanDuration(
            title: '1 MONTH',
            price: '₹498',
            perMonth: '₹499/mo',
            saving: "",
            selected: true,
          ),
          PlanDuration(
            title: '3 MONTHS',
            price: '₹1,299',
            perMonth: '₹433/mo',
            saving: 'SAVE 13%',
            selected: true,
          ),
          PlanDuration(
            title: '6 MONTHS',
            price: '₹2,399',
            perMonth: '₹400/mo',
            saving: 'SAVE 20%',
          ),
        ],
        weeklyBenefits: WeeklyBenefits(
          datePlans: '1',
          boosts: '1',
          compliments: '3',
          coins: '50',
        ),
        sections: [
          PlanSection(
            title: 'MATCH & DISCOVERY',
            emoji: '❤️',
            features: [
              PlanFeature(
                title: 'Unlimited likes',
                subtitle: 'No daily cap on swipes',
              ),
              PlanFeature(
                title: 'AI Compatibility Score',
                subtitle: 'See match % before liking',
              ),
              PlanFeature(
                title: 'See who liked you',
                subtitle: 'Secret Admirers revealed',
              ),
              PlanFeature(
                title: 'Advanced preference filters',
                subtitle: 'Verification, lifestyle, intent & more',
              ),
              PlanFeature(
                title: 'Rewind last swipe',
                subtitle: 'Undo an accidental pass',
              ),
              PlanFeature(
                title: 'Priority visibility',
                subtitle: 'Shown earlier in discovery',
              ),
            ],
          ),
          PlanSection(
            title: 'CHAT & MESSAGING',
            emoji: '💬',
            features: [
              PlanFeature(
                title: 'Unlimited chat requests',
                subtitle: 'Message without limits',
              ),
              PlanFeature(
                title: 'Voice & video calls',
                subtitle: 'In-app secure calling',
              ),
              PlanFeature(
                title: 'AI icebreakers',
                subtitle: 'Smart opener suggestions',
              ),
              PlanFeature(
                title: 'Read receipts',
                subtitle: 'Know when messages are seen',
              ),
              PlanFeature(
                title: 'Send & receive gifts & compliments',
                subtitle: 'Roses, gifts and compliments in chat',
              ),
            ],
          ),
          PlanSection(
            title: 'TRUST & VERIFICATION',
            emoji: '🛡️',
            features: [
              PlanFeature(
                title: 'ID verification badge',
                subtitle: 'Government-ID verified',
              ),
              PlanFeature(
                title: 'Education verification',
                subtitle: 'Degree & college confirmed',
              ),
              PlanFeature(
                title: 'Profession verification',
                subtitle: 'Job & company confirmed',
              ),
              PlanFeature(
                title: 'Fraud & scam protection',
                subtitle: 'Proactive risk checks',
              ),
              PlanFeature(
                title: 'Profile authenticity checks',
                subtitle: 'Anti-catfish screening',
              ),
            ],
          ),
          PlanSection(
            title: 'PRIVACY',
            emoji: '🔒',
            features: [
              PlanFeature(
                title: 'SafeFace photo privacy',
                subtitle: 'Blur photos until you reveal',
              ),
              PlanFeature(
                title: 'AI Avatar Studio',
                subtitle: 'Generate profile avatars',
              ),
            ],
          ),
          PlanSection(
            title: 'STATUS & BADGES',
            emoji: '🏆',
            features: [
              PlanFeature(
                title: 'AI Match score chip',
                subtitle: 'Compatibility % on your profile',
              ),
              PlanFeature(
                title: 'Trust Score chip + verified tick',
                subtitle: 'On-profile trust % and verified checkmark',
              ),
              PlanFeature(
                title: 'Fast-reply chip',
                subtitle: 'Average reply time shown',
              ),
              PlanFeature(
                title: 'Tier badge on profile',
                subtitle: 'Show your membership',
              ),
              PlanFeature(title: 'Marriage Intent badge'),
            ],
          ),
          PlanSection(
            title: 'REAL-LIFE & EVENTS',
            emoji: '🎉',
            features: [
              PlanFeature(
                title: 'Date Now invites',
                subtitle: 'Spontaneous live meetups',
              ),
              PlanFeature(
                title: 'Singles events access',
                subtitle: 'Curated offline events',
              ),
              PlanFeature(
                title: 'Safe meeting spots',
                subtitle: 'Verified public venues',
              ),
            ],
          ),
          PlanSection(
            title: 'PERKS & REWARDS',
            emoji: '🎁',
            features: [
              PlanFeature(
                title: 'Welcome coins',
                subtitle: '₹250 wallet coins on join',
              ),
              PlanFeature(
                title: 'Premium gift access',
                subtitle: 'Exclusive gift catalog',
              ),
              PlanFeature(
                title: 'Refer & earn bonus',
                subtitle: 'Wallet rewards for referrals',
              ),
            ],
          ),
          PlanSection(
            title: 'FOREVER LOVE PROGRAMME',
            emoji: '💍',
            features: [
              PlanFeature(
                title: '₹5 Lakh foreign trip reward',
                subtitle: 'Date 3 years on Welvors & get married',
              ),
              PlanFeature(
                title: '₹5,000/month shopping reward',
                subtitle: 'Paid for 3 years after your marriage',
              ),
            ],
          ),
        ],
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
        primaryColor: Color(0xFFE8A53D),
        secondaryColor: Color(0xFFA36D0C),
        textColor: Colors.white,
        durations: [
          PlanDuration(
            title: '1 MONTH',
            price: '₹1,999',
            perMonth: '₹1,999/mo',
          ),
          PlanDuration(
            title: '3 MONTHS',
            price: '₹5,499',
            perMonth: '₹1,833/mo',
            saving: 'SAVE 8%',
          ),
          PlanDuration(
            title: '6 MONTHS',
            price: '₹9,999',
            perMonth: '₹1,666/mo',
            saving: 'SAVE 16%',
            selected: true,
          ),
        ],
        weeklyBenefits: WeeklyBenefits(
          datePlans: '3',
          boosts: '3',
          compliments: '10',
          coins: '500',
        ),
        sections: [
          PlanSection(
            title: 'ELITE ACCESS',
            emoji: '💎',
            features: [
              PlanFeature(
                title: 'VIP-only member pool',
                subtitle: 'Browse premium verified profiles',
              ),
              PlanFeature(
                title: 'Priority visibility',
                subtitle: 'Shown first to other VIPs',
              ),
              PlanFeature(
                title: 'Priority messages',
                subtitle: 'Skip the queue with VIP members',
              ),
            ],
          ),
          PlanSection(
            title: 'MATCH & DISCOVERY',
            emoji: '❤️',
            features: [
              PlanFeature(
                title: 'Unlimited likes',
                subtitle: 'No daily cap on swipes',
              ),
              PlanFeature(
                title: 'AI Compatibility Score',
                subtitle: 'See match % before liking',
              ),
              PlanFeature(
                title: 'See who liked you',
                subtitle: 'Secret Admirers revealed',
              ),
              PlanFeature(
                title: 'Advanced preference filters',
                subtitle: 'VIP-grade filtering',
              ),
              PlanFeature(
                title: 'Rewind last swipe',
                subtitle: 'Undo an accidental pass',
              ),
            ],
          ),
          PlanSection(
            title: 'CHAT & MESSAGING',
            emoji: '💬',
            features: [
              PlanFeature(title: 'Unlimited chat requests'),
              PlanFeature(title: 'Voice & video calls'),
              PlanFeature(title: 'AI icebreakers'),
              PlanFeature(title: 'Read receipts'),
              PlanFeature(title: 'Send & receive gifts & compliments'),
            ],
          ),
          PlanSection(
            title: 'STATUS & PRIVACY',
            emoji: '🏆',
            features: [
              PlanFeature(title: 'Gold VIP badge'),
              PlanFeature(title: '"Seeking Elite" tag'),
              PlanFeature(
                title: 'Ghost / incognito mode',
                subtitle: 'Browse privately',
              ),
              PlanFeature(title: 'SafeFace photo privacy'),
            ],
          ),
          PlanSection(
            title: 'ADVANCED TRUST',
            emoji: '🛡️',
            features: [
              PlanFeature(title: 'ID verification badge'),
              PlanFeature(title: 'Education verification'),
              PlanFeature(title: 'Profession verification'),
              PlanFeature(
                title: 'Platinum verification',
                subtitle: 'Highest trust tier',
              ),
              PlanFeature(title: 'Profile authenticity checks'),
            ],
          ),
          PlanSection(
            title: 'PREMIUM EXPERIENCES',
            emoji: '✨',
            features: [
              PlanFeature(
                title: 'Luxury date planning',
                subtitle: 'Fine dining, premium venues',
              ),
              PlanFeature(
                title: 'VIP events access',
                subtitle: 'Rooftop socials, private mixers',
              ),
              PlanFeature(
                title: 'Adventure experiences',
                subtitle: 'Treks, retreats, travel meetups',
              ),
            ],
          ),
          PlanSection(
            title: 'NETWORKING & GROWTH',
            emoji: '💼',
            features: [
              PlanFeature(
                title: 'Career networking',
                subtitle: 'Connect with professionals',
              ),
              PlanFeature(title: 'Mentorship requests'),
              PlanFeature(title: 'Startup & business connections'),
            ],
          ),
          PlanSection(
            title: 'VIP PERKS',
            emoji: '🎁',
            features: [
              PlanFeature(
                title: 'Welcome coins',
                subtitle: '₹500 wallet bonus',
              ),
              PlanFeature(title: 'Premium gift access'),
              PlanFeature(
                title: 'Seasonal rewards',
                subtitle: 'Exclusive limited-time perks',
              ),
              PlanFeature(title: 'Refer & earn bonus'),
            ],
          ),
        ],
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
        primaryColor: Color(0xFF171717),
        secondaryColor: Color(0xFF050505),
        textColor: Colors.white,
        durations: [
          PlanDuration(
            title: '1 MONTH TRIAL',
            price: '₹6,999',
            perMonth: 'Per month',
          ),
          PlanDuration(
            title: '3 MONTHS',
            price: '₹18,999',
            perMonth: '₹6,333/mo',
            saving: 'SAVE 10%',
          ),
          PlanDuration(
            title: 'LIFETIME',
            price: '₹1,99,999',
            perMonth: 'Lifetime',
            selected: true,
          ),
        ],
        weeklyBenefits: WeeklyBenefits(
          datePlans: '10',
          boosts: '10',
          compliments: '30',
          coins: '2000',
        ),
        sections: [
          PlanSection(
            title: 'EVERYTHING IN VIP',
            emoji: '✓',
            features: [
              PlanFeature(
                title: 'All VIP features included',
                subtitle: 'Plus elite-only access below',
              ),
            ],
          ),
          PlanSection(
            title: 'MAXIMUM PRIVACY',
            emoji: '🔒',
            features: [
              PlanFeature(
                title: 'Elite-only discovery feed',
                subtitle: 'Invitation-only pool',
              ),
              PlanFeature(
                title: 'Visibility control',
                subtitle: 'Elite only / Elite + VIP — you decide',
              ),
              PlanFeature(title: 'Hidden photos until mutual interest'),
              PlanFeature(title: 'Approximate location privacy'),
              PlanFeature(
                title: 'Screenshot alerts',
                subtitle: 'Know if someone screenshots',
              ),
            ],
          ),
          PlanSection(
            title: 'CURATED ELITE MATCHING',
            emoji: '🎯',
            features: [
              PlanFeature(title: 'Lifestyle & ambition compatibility'),
              PlanFeature(title: 'Curated premium recommendations'),
              PlanFeature(title: 'High-trust member ecosystem'),
            ],
          ),
          PlanSection(
            title: 'ELITE STATUS',
            emoji: '👑',
            features: [
              PlanFeature(title: 'Gold Crown (Elite) badge'),
              PlanFeature(title: 'Platinum verified profile'),
              PlanFeature(title: 'Highest trust-tier verification'),
            ],
          ),
          PlanSection(
            title: 'WHITE-GLOVE EXPERIENCES',
            emoji: '✨',
            features: [
              PlanFeature(
                title: 'Personal date concierge',
                subtitle: 'White-glove planning',
              ),
              PlanFeature(title: 'Premium itinerary planning'),
              PlanFeature(title: 'Luxury venue recommendations'),
              PlanFeature(title: 'Members-only curated gatherings'),
            ],
          ),
          PlanSection(
            title: 'GLOBAL EXPERIENCES',
            emoji: '✈️',
            features: [
              PlanFeature(title: 'International premium dates'),
              PlanFeature(title: 'Luxury travel recommendations'),
              PlanFeature(title: 'Exclusive global events'),
            ],
          ),
        ],
      );

      // Now map API data to our models
      MembershipPlanModel mergedPremium = defaultPremium;
      MembershipPlanModel mergedVip = defaultVip;
      MembershipPlanModel mergedElite = defaultElite;

      for (var pkg in apiPackages) {
        final slug = pkg['slug']?.toString().toLowerCase() ?? '';
        final id = pkg['id']?.toString() ?? '';
        final price = pkg['price']?.toString() ?? '';
        final name = pkg['name']?.toString() ?? '';
        final badgeLabel = pkg['badgeLabel']?.toString();
        final features = pkg['features'] as List<dynamic>?;
        
        if (slug == 'premium') {
          mergedPremium = _mergeWithApi(defaultPremium, id, name, price, features, badgeLabel);
        } else if (slug == 'vip') {
          mergedVip = _mergeWithApi(defaultVip, id, name, price, features, badgeLabel);
        } else if (slug == 'vip-elite' || slug == 'vip_elite' || slug == 'elite') {
          mergedElite = _mergeWithApi(defaultElite, id, name, price, features, badgeLabel);
        }
      }

      return [mergedPremium, mergedVip, mergedElite];
  }

  MembershipPlanModel _mergeWithApi(
      MembershipPlanModel base, String id, String name, String price, List<dynamic>? features, String? badgeLabel) {
    
    // We update the monthlyPrice and ID from the API.
    final newPriceStr = price.isNotEmpty ? '₹$price' : base.monthlyPrice;
    
    return MembershipPlanModel(
      id: id.isNotEmpty ? id : base.id,
      tier: base.tier,
      name: name.isNotEmpty ? name : base.name,
      badge: base.badge,
      badgeLabel: badgeLabel,
      emoji: base.emoji,
      description: base.description,
      monthlyPrice: newPriceStr,
      yearlyPrice: base.yearlyPrice,
      yearlySaving: base.yearlySaving,
      primaryColor: base.primaryColor,
      secondaryColor: base.secondaryColor,
      textColor: base.textColor,
      durations: base.durations,
      weeklyBenefits: base.weeklyBenefits,
      sections: base.sections,
      rawFeatures: features,
    );
  }
}
