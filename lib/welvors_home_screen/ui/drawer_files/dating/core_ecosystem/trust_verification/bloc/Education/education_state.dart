import '../../Model/education_model.dart';

abstract class EducationState {}

class EducationInitial extends EducationState {}

class EducationLoading extends EducationState {}

class EducationLoaded extends EducationState {
  final EducationResponse response;

  EducationLoaded(this.response);
}

class EducationError extends EducationState {
  final String message;

  EducationError(this.message);
}
