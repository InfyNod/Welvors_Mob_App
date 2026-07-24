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

  const BoostState({
    required this.boostBalance,
    required this.superBoostBalance,
    required this.history,
  });

  bool get isAnyBoostActive {
    if (history.isEmpty) return false;
    final latest = history.first;
    final totalDuration = latest.isSuperBoost 
        ? const Duration(hours: 3) 
        : const Duration(hours: 1);
    return DateTime.now().difference(latest.date) < totalDuration;
  }

  factory BoostState.initial() {
    return BoostState(
      boostBalance: 0,
      superBoostBalance: 0,
      history: const [],
    );
  }

  BoostState copyWith({
    int? boostBalance,
    int? superBoostBalance,
    List<BoostHistoryItem>? history,
  }) {
    return BoostState(
      boostBalance: boostBalance ?? this.boostBalance,
      superBoostBalance: superBoostBalance ?? this.superBoostBalance,
      history: history ?? this.history,
    );
  }

  @override
  List<Object> get props => [boostBalance, superBoostBalance, history];
}
