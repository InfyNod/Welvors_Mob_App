abstract class AdmirersState {}

class AdmirersInitial extends AdmirersState {}

class AdmirersLoading extends AdmirersState {}

class AdmirersLoaded extends AdmirersState {
  final int coins;
  final List<Map<String, dynamic>> likes;
  final List<Map<String, dynamic>> sentLikes; // newly added
  final List<Map<String, dynamic>> roses;
  final List<Map<String, dynamic>> sentRoses; // newly added
  final String activeTab; // 'likes', 'roses', 'vip'
  final bool isLocked;
  final int? receivedLikesCount;

  int get likesCount => receivedLikesCount ?? likes.length;
  int get rosesCount => roses.length;

  AdmirersLoaded({
    required this.coins,
    required this.likes,
    required this.sentLikes,
    required this.roses,
    required this.sentRoses,
    required this.activeTab,
    this.isLocked = false,
    this.receivedLikesCount,
  });

  AdmirersLoaded copyWith({
    int? coins,
    List<Map<String, dynamic>>? likes,
    List<Map<String, dynamic>>? sentLikes,
    List<Map<String, dynamic>>? roses,
    List<Map<String, dynamic>>? sentRoses,
    String? activeTab,
    bool? isLocked,
    int? receivedLikesCount,
  }) {
    return AdmirersLoaded(
      coins: coins ?? this.coins,
      likes: likes ?? this.likes,
      sentLikes: sentLikes ?? this.sentLikes,
      roses: roses ?? this.roses,
      sentRoses: sentRoses ?? this.sentRoses,
      activeTab: activeTab ?? this.activeTab,
      isLocked: isLocked ?? this.isLocked,
      receivedLikesCount: receivedLikesCount ?? this.receivedLikesCount,
    );
  }
}
