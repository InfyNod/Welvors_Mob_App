import '../../../Model/professional_verfication_model.dart';

abstract class professional_verficationState {}

class professional_verficationInitial extends professional_verficationState {}

class professional_verficationLoading extends professional_verficationState {}

class professional_verficationLoaded extends professional_verficationState {
  final ProfessionalVerificationResponse response;

  professional_verficationLoaded(this.response);
}

class professional_verficationError extends professional_verficationState {
  final String message;

  professional_verficationError(this.message);
}
