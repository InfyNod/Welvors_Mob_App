part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {
  final bool isRefresh;
  const LoadHomeDataEvent({this.isRefresh = false});
  @override
  List<Object> get props => [isRefresh];
}

class SwipeProfileEvent extends HomeEvent {
  final bool isRightSwipe;
  const SwipeProfileEvent({required this.isRightSwipe});

  @override
  List<Object> get props => [isRightSwipe];
}

class UndoSwipeEvent extends HomeEvent {}

class FetchProfileDetailsEvent extends HomeEvent {
  final String userId;
  const FetchProfileDetailsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
