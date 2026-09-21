import 'package:equatable/equatable.dart';

class BoostHistoryItem extends Equatable {
  final String? id;
  final String title;
  final DateTime date;
  final int reach;
  final int likes;
  final int interests;
  final String duration;
  final bool isSuperBoost;
  final String? status;
  final DateTime? expectedEndAt;

  const BoostHistoryItem({
    this.id,
    required this.title,
    required this.date,
    required this.reach,
    required this.likes,
    required this.interests,
    required this.duration,
    this.isSuperBoost = false,
    this.status,
    this.expectedEndAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    date,
    reach,
    likes,
    interests,
    duration,
    isSuperBoost,
    status,
    expectedEndAt,
  ];
}

class BoostState extends Equatable {
  final int boostBalance;
  final int superBoostBalance;
  final List<BoostHistoryItem> history;
  final bool isLoading;
  final bool isActive;
  final DateTime? expiresAt;
  final List<Map<String, dynamic>> benefits;
  final String? userBoostId;

  // Super Boost properties
  final bool superIsActive;
  final DateTime? superExpiresAt;
  final List<Map<String, dynamic>> superBenefits;
  final String? superUserBoostId;

  // Lifetime Impact properties
  final int totalReach;
  final int newLikes;
  final int interests;
  final int views;
  final int matches;

  const BoostState({
    required this.boostBalance,
    required this.superBoostBalance,
    required this.history,
    this.isLoading = false,
    this.isActive = false,
    this.expiresAt,
    this.benefits = const [],
    this.userBoostId,
    this.superIsActive = false,
    this.superExpiresAt,
    this.superBenefits = const [],
    this.superUserBoostId,
    this.totalReach = 0,
    this.newLikes = 0,
    this.interests = 0,
    this.views = 0,
    this.matches = 0,
  });

  bool get isAnyBoostActive {
    if (isActive && expiresAt != null) {
      if (expiresAt!.isAfter(DateTime.now())) {
        return true;
      }
    }
    if (history.isEmpty) return false;
    final latest = history.first;
    final totalDuration = latest.isSuperBoost
        ? const Duration(hours: 3)
        : const Duration(hours: 1);
    return DateTime.now().difference(latest.date) < totalDuration;
  }

  factory BoostState.initial() {
    return const BoostState(
      boostBalance: 0,
      superBoostBalance: 0,
      history: [],
      isLoading: false,
      isActive: false,
      benefits: [],
      userBoostId: null,
      superIsActive: false,
      superBenefits: [],
      superUserBoostId: null,
    );
  }

  BoostState copyWith({
    int? boostBalance,
    int? superBoostBalance,
    List<BoostHistoryItem>? history,
    bool? isLoading,
    bool? isActive,
    DateTime? expiresAt,
    List<Map<String, dynamic>>? benefits,
    String? userBoostId,
    bool? superIsActive,
    DateTime? superExpiresAt,
    List<Map<String, dynamic>>? superBenefits,
    String? superUserBoostId,
    int? totalReach,
    int? newLikes,
    int? interests,
    int? views,
    int? matches,
  }) {
    return BoostState(
      boostBalance: boostBalance ?? this.boostBalance,
      superBoostBalance: superBoostBalance ?? this.superBoostBalance,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
      benefits: benefits ?? this.benefits,
      userBoostId: userBoostId ?? this.userBoostId,
      superIsActive: superIsActive ?? this.superIsActive,
      superExpiresAt: superExpiresAt ?? this.superExpiresAt,
      superBenefits: superBenefits ?? this.superBenefits,
      superUserBoostId: superUserBoostId ?? this.superUserBoostId,
      totalReach: totalReach ?? this.totalReach,
      newLikes: newLikes ?? this.newLikes,
      interests: interests ?? this.interests,
      views: views ?? this.views,
      matches: matches ?? this.matches,
    );
  }

  @override
  List<Object?> get props => [
    boostBalance,
    superBoostBalance,
    history,
    isLoading,
    isActive,
    expiresAt,
    benefits,
    userBoostId,
    superIsActive,
    superExpiresAt,
    superBenefits,
    superUserBoostId,
    totalReach,
    newLikes,
    interests,
    views,
    matches,
  ];
}
