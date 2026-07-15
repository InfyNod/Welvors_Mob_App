part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {}

class SwipeProfileEvent extends HomeEvent {
  final bool isRightSwipe;
  const SwipeProfileEvent({required this.isRightSwipe});

  @override
  List<Object> get props => [isRightSwipe];
}

class UndoSwipeEvent extends HomeEvent {}
