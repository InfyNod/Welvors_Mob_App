enum NotificationStatus { initial, loading, loaded, error }

class NotificationState {
  final NotificationStatus status;
  final List<Map<String, dynamic>> allNotifications;
  final List<Map<String, dynamic>> displayedNotifications;
  final int selectedTabIndex;
  final String? errorMessage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.allNotifications = const [],
    this.displayedNotifications = const [],
    this.selectedTabIndex = 0,
    this.errorMessage,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<Map<String, dynamic>>? allNotifications,
    List<Map<String, dynamic>>? displayedNotifications,
    int? selectedTabIndex,
    String? errorMessage,
  }) {
    return NotificationState(
      status: status ?? this.status,
      allNotifications: allNotifications ?? this.allNotifications,
      displayedNotifications: displayedNotifications ?? this.displayedNotifications,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
