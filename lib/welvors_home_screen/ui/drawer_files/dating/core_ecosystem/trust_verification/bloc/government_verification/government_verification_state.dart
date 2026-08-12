import '../../Model/government_verification_response.dart';

abstract class GovernmentVerificationState {}

class GovernmentVerificationInitial extends GovernmentVerificationState {}

class GovernmentVerificationLoading extends GovernmentVerificationState {}

class GovernmentVerificationLoaded extends GovernmentVerificationState {
  final GovernmentVerificationResponse response;

  GovernmentVerificationLoaded(this.response);
}

class GovernmentVerificationError extends GovernmentVerificationState {
  final String message;

  GovernmentVerificationError(this.message);
}
