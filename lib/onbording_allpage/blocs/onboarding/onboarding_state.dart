import 'package:equatable/equatable.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingSuccess extends OnboardingState {
  final dynamic data; // Optional data returned from fetch API

  const OnboardingSuccess([this.data]);

  @override
  List<Object?> get props => [data];
}

class OnboardingFailure extends OnboardingState {
  final String error;

  const OnboardingFailure(this.error);

  @override
  List<Object?> get props => [error];
}
