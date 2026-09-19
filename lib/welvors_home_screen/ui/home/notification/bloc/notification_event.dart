import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Initial API load
class LoadNotifications extends NotificationEvent {
  final bool refresh;

  const LoadNotifications({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

/// Change notification tab
class FilterNotifications extends NotificationEvent {
  final int tabIndex;
  final String tabName;

  const FilterNotifications({required this.tabIndex, required this.tabName});

  @override
  List<Object?> get props => [tabIndex, tabName];
}

/// Mark single notification as read
class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read
class MarkAllAsRead extends NotificationEvent {
  const MarkAllAsRead();
}

/// Load next page
class LoadMoreNotifications extends NotificationEvent {
  const LoadMoreNotifications();
}
