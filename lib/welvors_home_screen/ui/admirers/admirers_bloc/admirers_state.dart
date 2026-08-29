abstract class AdmirersState {}

class AdmirersInitial extends AdmirersState {}

class AdmirersLoading extends AdmirersState {}

class AdmirersLoaded extends AdmirersState {
  final int coins;
  final List<Map<String, dynamic>> likes;
  final List<Map<String, dynamic>> roses;
  final String activeTab; // 'likes', 'roses', 'vip'

  int get likesCount => likes.length;
  int get rosesCount => roses.length;

  AdmirersLoaded({
    required this.coins,
    required this.likes,
    required this.roses,
    required this.activeTab,
  });

  AdmirersLoaded copyWith({
    int? coins,
    List<Map<String, dynamic>>? likes,
    List<Map<String, dynamic>>? roses,
    String? activeTab,
  }) {
    return AdmirersLoaded(
      coins: coins ?? this.coins,
      likes: likes ?? this.likes,
      roses: roses ?? this.roses,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}
