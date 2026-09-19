import 'package:equatable/equatable.dart';

enum NotificationStatus { initial, loading, loaded, error, loadingMore }

class NotificationState extends Equatable {
  final NotificationStatus status;

  /// All API notifications
  final List<Map<String, dynamic>> allNotifications;

  /// Notifications currently visible after filtering
  final List<Map<String, dynamic>> displayedNotifications;

  final int selectedTabIndex;
  final String selectedTabName;

  final int unreadCount;

  final int currentPage;
  final int totalPages;
  final int limit;

  final bool hasMore;

  final String? errorMessage;

  const NotificationState({
    this.status = NotificationStatus.initial,
    this.allNotifications = const [],
    this.displayedNotifications = const [],
    this.selectedTabIndex = 0,
    this.selectedTabName = 'All',
    this.unreadCount = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.limit = 20,
    this.hasMore = false,
    this.errorMessage,
  });

  NotificationState copyWith({
    NotificationStatus? status,
    List<Map<String, dynamic>>? allNotifications,
    List<Map<String, dynamic>>? displayedNotifications,
    int? selectedTabIndex,
    String? selectedTabName,
    int? unreadCount,
    int? currentPage,
    int? totalPages,
    int? limit,
    bool? hasMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationState(
      status: status ?? this.status,
      allNotifications: allNotifications ?? this.allNotifications,
      displayedNotifications:
          displayedNotifications ?? this.displayedNotifications,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedTabName: selectedTabName ?? this.selectedTabName,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allNotifications,
    displayedNotifications,
    selectedTabIndex,
    selectedTabName,
    unreadCount,
    currentPage,
    totalPages,
    limit,
    hasMore,
    errorMessage,
  ];
}
