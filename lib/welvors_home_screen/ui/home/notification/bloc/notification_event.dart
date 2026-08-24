abstract class NotificationEvent {}

class LoadNotifications extends NotificationEvent {}

class FilterNotifications extends NotificationEvent {
  final int tabIndex;
  final String tabName;

  FilterNotifications({required this.tabIndex, required this.tabName});
}

class MarkAllAsRead extends NotificationEvent {}
