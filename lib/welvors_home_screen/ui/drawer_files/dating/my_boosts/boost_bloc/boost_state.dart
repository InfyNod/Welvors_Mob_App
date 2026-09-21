import 'package:equatable/equatable.dart';

class BoostHistoryItem extends Equatable {
  final String title;
  final DateTime date;
  final int reach;
  final int likes;
  final int interests;
  final String duration;
  final bool isSuperBoost;

  const BoostHistoryItem({
    required this.title,
    required this.date,
    required this.reach,
    required this.likes,
    required this.interests,
    required this.duration,
    this.isSuperBoost = false,
  });

  @override
  List<Object> get props => [title, date, reach, likes, interests, duration, isSuperBoost];
}

class BoostState extends Equatable {
  final int boostBalance;
  final int superBoostBalance;
  final List<BoostHistoryItem> history;
  final bool isLoading;
  final bool isActive;
  final DateTime? expiresAt;
  final List<Map<String, dynamic>> benefits;

  // Super Boost properties
  final bool superIsActive;
  final DateTime? superExpiresAt;
  final List<Map<String, dynamic>> superBenefits;

  const BoostState({
    required this.boostBalance,
    required this.superBoostBalance,
    required this.history,
    this.isLoading = false,
    this.isActive = false,
    this.expiresAt,
    this.benefits = const [],
    this.superIsActive = false,
    this.superExpiresAt,
    this.superBenefits = const [],
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
      superIsActive: false,
      superBenefits: [],
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
    bool? superIsActive,
    DateTime? superExpiresAt,
    List<Map<String, dynamic>>? superBenefits,
  }) {
    return BoostState(
      boostBalance: boostBalance ?? this.boostBalance,
      superBoostBalance: superBoostBalance ?? this.superBoostBalance,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
      benefits: benefits ?? this.benefits,
      superIsActive: superIsActive ?? this.superIsActive,
      superExpiresAt: superExpiresAt ?? this.superExpiresAt,
      superBenefits: superBenefits ?? this.superBenefits,
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
        superIsActive,
        superExpiresAt,
        superBenefits,
      ];
}
