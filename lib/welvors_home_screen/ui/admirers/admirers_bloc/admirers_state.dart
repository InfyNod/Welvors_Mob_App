abstract class AdmirersState {}

class AdmirersInitial extends AdmirersState {}

class AdmirersLoading extends AdmirersState {}

class AdmirersLoaded extends AdmirersState {
  final int coins;
  final int likesCount;
  final int rosesCount;
  final String activeTab; // 'likes', 'roses', 'vip'

  AdmirersLoaded({
    required this.coins,
    required this.likesCount,
    required this.rosesCount,
    required this.activeTab,
  });

  AdmirersLoaded copyWith({
    int? coins,
    int? likesCount,
    int? rosesCount,
    String? activeTab,
  }) {
    return AdmirersLoaded(
      coins: coins ?? this.coins,
      likesCount: likesCount ?? this.likesCount,
      rosesCount: rosesCount ?? this.rosesCount,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}
