import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velvors/welvors_home_screen/ui/home/notification/bloc/notification_repository.dart';

import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({NotificationRepository? repository})
    : repository = repository ?? NotificationRepository(),
      super(const NotificationState()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<FilterNotifications>(_onFilterNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<LoadMoreNotifications>(_onLoadMoreNotifications);
  }

  // ============================================================
  // LOAD NOTIFICATIONS
  // ============================================================

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.status == NotificationStatus.loading && !event.refresh) {
      return;
    }

    emit(
      state.copyWith(
        status: NotificationStatus.loading,
        errorMessage: null,
        clearError: true,
      ),
    );

    try {
      // ============================================================
      // GET NOTIFICATIONS
      // ============================================================

      final response = await repository.fetchNotifications(category: 'ALL');

      print('🔔 Notifications fetched');

      final rawNotifications = _extractNotifications(response);

      final mappedNotifications = rawNotifications
          .map(_mapNotification)
          .toList();

      final pagination = _extractPagination(response);

      final currentPage = _toInt(pagination['page']) ?? 1;

      final totalPages = _toInt(pagination['totalPages']) ?? 1;

      final limit = _toInt(pagination['limit']) ?? state.limit;

      // ============================================================
      // GET UNREAD COUNT FROM SEPARATE API
      // ============================================================

      int unreadCount = 0;

      try {
        unreadCount = await repository.getUnreadNotificationCount();

        print('🔔 SEPARATE UNREAD COUNT: $unreadCount');
      } catch (e) {
        print('❌ Unread count API error: $e');

        // Fallback to notification response
        unreadCount = _extractUnreadCount(response, mappedNotifications);
      }

      // ============================================================
      // FILTER
      // ============================================================

      final displayed = _filterList(
        mappedNotifications,
        state.selectedTabIndex,
      );

      // ============================================================
      // UPDATE STATE
      // ============================================================

      emit(
        state.copyWith(
          status: NotificationStatus.loaded,
          allNotifications: mappedNotifications,
          displayedNotifications: displayed,
          unreadCount: unreadCount,
          currentPage: currentPage,
          totalPages: totalPages,
          limit: limit,
          hasMore: currentPage < totalPages,
          clearError: true,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Notification load error: $e');

      debugPrint('$stackTrace');

      emit(
        state.copyWith(
          status: NotificationStatus.error,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  // ============================================================
  // LOAD MORE
  // ============================================================

  Future<void> _onLoadMoreNotifications(
    LoadMoreNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    if (!state.hasMore) {
      return;
    }

    if (state.status == NotificationStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: NotificationStatus.loadingMore));

    try {
      final nextPage = state.currentPage + 1;

      final response = await repository.fetchNotifications(
        // page: nextPage,
        // limit: state.limit,
      );

      final rawNotifications = _extractNotifications(response);

      final mappedNotifications = rawNotifications
          .map(_mapNotification)
          .toList();

      final pagination = _extractPagination(response);

      final currentPage = _toInt(pagination['page']) ?? nextPage;

      final totalPages = _toInt(pagination['totalPages']) ?? state.totalPages;

      final merged = [...state.allNotifications, ...mappedNotifications];

      final unique = _removeDuplicates(merged);

      final unreadCount = _extractUnreadCount(response, unique);

      final displayed = _filterList(unique, state.selectedTabIndex);

      emit(
        state.copyWith(
          status: NotificationStatus.loaded,
          allNotifications: unique,
          displayedNotifications: displayed,
          unreadCount: unreadCount,
          currentPage: currentPage,
          totalPages: totalPages,
          hasMore: currentPage < totalPages,
        ),
      );
    } catch (e) {
      debugPrint('❌ Notification pagination error: $e');

      emit(state.copyWith(status: NotificationStatus.loaded));
    }
  }

  // ============================================================
  // FILTER
  // ============================================================

  void _onFilterNotifications(
    FilterNotifications event,
    Emitter<NotificationState> emit,
  ) {
    final filtered = _filterList(state.allNotifications, event.tabIndex);

    emit(
      state.copyWith(
        selectedTabIndex: event.tabIndex,
        selectedTabName: event.tabName,
        displayedNotifications: filtered,
      ),
    );
  }

  // ============================================================
  // MARK SINGLE READ
  // ============================================================

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final notificationId = event.notificationId;

    if (notificationId.isEmpty) {
      return;
    }

    final currentList = List<Map<String, dynamic>>.from(state.allNotifications);

    final index = currentList.indexWhere(
      (notification) => notification['id']?.toString() == notificationId,
    );

    if (index == -1) {
      return;
    }

    // Optimistic UI update
    currentList[index] = {
      ...currentList[index],
      'isUnread': false,
      'isRead': true,
    };

    final unreadCount = currentList
        .where((notification) => notification['isUnread'] == true)
        .length;

    emit(
      state.copyWith(
        allNotifications: currentList,
        displayedNotifications: _filterList(
          currentList,
          state.selectedTabIndex,
        ),
        unreadCount: unreadCount,
      ),
    );

    try {
      await repository.markNotificationAsRead(notificationId);
    } catch (e) {
      debugPrint('❌ Mark notification read API error: $e');

      // UI stays read because optimistic update.
      // If backend fails, next refresh will restore actual state.
    }
  }

  // ============================================================
  // MARK ALL READ
  // ============================================================

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    final currentList = state.allNotifications.map((notification) {
      return {...notification, 'isUnread': false, 'isRead': true};
    }).toList();

    emit(
      state.copyWith(
        allNotifications: currentList,
        displayedNotifications: _filterList(
          currentList,
          state.selectedTabIndex,
        ),
        unreadCount: 0,
      ),
    );

    try {
      await repository.markAllNotificationsAsRead();
    } catch (e) {
      debugPrint('❌ Mark all read API error: $e');
    }
  }

  // ============================================================
  // EXTRACT NOTIFICATIONS
  // ============================================================

  List<dynamic> _extractNotifications(Map<String, dynamic> response) {
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      final notifications = data['notifications'];

      if (notifications is List) {
        return notifications;
      }
    }

    return [];
  }

  // ============================================================
  // EXTRACT PAGINATION
  // ============================================================

  Map<String, dynamic> _extractPagination(Map<String, dynamic> response) {
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      final pagination = data['pagination'];

      if (pagination is Map) {
        return Map<String, dynamic>.from(pagination);
      }
    }

    return {};
  }

  // ============================================================
  // UNREAD COUNT
  // ============================================================

  int _extractUnreadCount(
    Map<String, dynamic> response,
    List<Map<String, dynamic>> notifications,
  ) {
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      final count = _toInt(data['unreadCount']);

      if (count != null) {
        return count;
      }
    }

    return notifications
        .where((notification) => notification['isUnread'] == true)
        .length;
  }

  // ============================================================
  // MAP API NOTIFICATION TO UI
  // ============================================================

  Map<String, dynamic> _mapNotification(dynamic raw) {
    final notification = Map<String, dynamic>.from(raw as Map);

    final sender = notification['sender'] is Map
        ? Map<String, dynamic>.from(notification['sender'])
        : <String, dynamic>{};

    final type = notification['type']?.toString() ?? '';

    final title = notification['title']?.toString() ?? '';

    final message = notification['message']?.toString() ?? '';

    final id = notification['id']?.toString() ?? '';

    final photo = sender['photo']?.toString();

    final isRead = notification['isRead'] == true;

    final mapped = <String, dynamic>{
      // Original API fields
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'data': notification['data'],
      'isRead': isRead,
      'isUnread': !isRead,
      'readAt': notification['readAt'],
      'createdAt': notification['createdAt'],
      'sender': sender,

      // UI fields
      'avatarUrl': photo != null && photo.isNotEmpty ? photo : null,

      'subtitle': message,

      'time': _formatTime(notification['createdAt']),

      'buttonText': null,
      'isSecondaryButton': false,
      'isItalic': false,

      'icon': null,
      'iconBgColor': Colors.grey.shade100,
      'iconColor': Colors.grey.shade600,

      'badgeIcon': null,
      'badgeColor': const Color(0xFFE43A6A),
    };

    _applyNotificationType(mapped, type);

    return mapped;
  }

  // ============================================================
  // TYPE DESIGN
  // ============================================================

  void _applyNotificationType(Map<String, dynamic> notification, String type) {
    switch (type) {
      // --------------------------------------------------------
      // NEW MATCH
      // --------------------------------------------------------

      case 'NEW_MATCH':
      case 'MATCH':
        notification['badgeIcon'] = Icons.favorite_rounded;

        notification['badgeColor'] = const Color(0xFFE43A6A);

        break;

      // --------------------------------------------------------
      // NEW ROSE
      // --------------------------------------------------------

      case 'NEW_ROSE':
      case 'ROSE':
        notification['avatarUrl'] = null;

        notification['icon'] = Icons.local_florist_rounded;

        notification['iconBgColor'] = const Color(0xFFFFE8EF);

        notification['iconColor'] = const Color(0xFFE43A6A);

        break;

      // --------------------------------------------------------
      // DATE INVITE
      // --------------------------------------------------------

      case 'DATE_INVITE':
        notification['badgeIcon'] = Icons.calendar_month_rounded;

        notification['badgeColor'] = const Color(0xFFE43A6A);

        break;

      // --------------------------------------------------------
      // DATE CONFIRMED
      // --------------------------------------------------------

      case 'DATE_CONFIRMED':
        notification['badgeIcon'] = Icons.event_available_rounded;

        notification['badgeColor'] = const Color(0xFF10B981);

        break;

      // --------------------------------------------------------
      // GIFTS
      // --------------------------------------------------------

      case 'NEW_GIFT':
      case 'GIFT':
      case 'GIFT_RECEIVED':
        notification['badgeIcon'] = Icons.card_giftcard_rounded;

        notification['badgeColor'] = const Color(0xFFE43A6A);

        break;

      // --------------------------------------------------------
      // LIKE
      // --------------------------------------------------------

      case 'NEW_LIKE':
      case 'LIKE':
        notification['badgeIcon'] = Icons.favorite_rounded;

        notification['badgeColor'] = const Color(0xFFE43A6A);

        break;

      // --------------------------------------------------------
      // DEFAULT
      // --------------------------------------------------------

      default:
        notification['icon'] = Icons.notifications_none_rounded;

        notification['iconBgColor'] = const Color(0xFFF3F4F6);

        notification['iconColor'] = const Color(0xFF6B7280);

        break;
    }
  }

  // ============================================================
  // FILTER LIST
  // ============================================================

  List<Map<String, dynamic>> _filterList(
    List<Map<String, dynamic>> notifications,
    int tabIndex,
  ) {
    if (tabIndex == 0) {
      return List<Map<String, dynamic>>.from(notifications);
    }

    return notifications.where((notification) {
      final type = notification['type']?.toString() ?? '';

      switch (tabIndex) {
        // Likes & roses
        case 1:
          return type == 'NEW_LIKE' ||
              type == 'LIKE' ||
              type == 'NEW_ROSE' ||
              type == 'ROSE';

        // Matches
        case 2:
          return type == 'NEW_MATCH' || type == 'MATCH';

        // Gifts
        case 3:
          return type == 'NEW_GIFT' ||
              type == 'GIFT' ||
              type == 'GIFT_RECEIVED';

        // Dates
        case 4:
          return type == 'DATE_INVITE' || type == 'DATE_CONFIRMED';

        // Events
        case 5:
          return type == 'EVENT' ||
              type == 'NEW_EVENT' ||
              type == 'EVENT_INVITE';

        default:
          return true;
      }
    }).toList();
  }

  // ============================================================
  // REMOVE DUPLICATES
  // ============================================================

  List<Map<String, dynamic>> _removeDuplicates(
    List<Map<String, dynamic>> notifications,
  ) {
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];

    for (final notification in notifications) {
      final id = notification['id']?.toString() ?? '';

      if (id.isEmpty) {
        result.add(notification);
        continue;
      }

      if (seen.add(id)) {
        result.add(notification);
      }
    }

    return result;
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(dynamic value) {
    if (value == null) {
      return '';
    }

    try {
      final date = DateTime.parse(value.toString()).toLocal();

      final now = DateTime.now();

      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Just now';
      }

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      }

      if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      }

      if (difference.inDays == 1) {
        return 'Yesterday';
      }

      if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      }

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return value.toString();
    }
  }

  // ============================================================
  // INT PARSER
  // ============================================================

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }
}
