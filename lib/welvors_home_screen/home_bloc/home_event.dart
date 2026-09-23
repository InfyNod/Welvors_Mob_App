part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {
  final bool isRefresh;
  final Map<String, dynamic>? filters;

  const LoadHomeDataEvent({
    this.isRefresh = false,
    this.filters,
  });

  @override
  List<Object?> get props => [isRefresh, filters];
}

class SwipeProfileEvent extends HomeEvent {
  final bool isRightSwipe;
  const SwipeProfileEvent({required this.isRightSwipe});

  @override
  List<Object?> get props => [isRightSwipe];
}

class UndoSwipeEvent extends HomeEvent {}

class FetchProfileDetailsEvent extends HomeEvent {
  final String userId;
  const FetchProfileDetailsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RemoveProfileEvent extends HomeEvent {
  final String profileId;
  const RemoveProfileEvent({required this.profileId});

  @override
  List<Object?> get props => [profileId];
}
