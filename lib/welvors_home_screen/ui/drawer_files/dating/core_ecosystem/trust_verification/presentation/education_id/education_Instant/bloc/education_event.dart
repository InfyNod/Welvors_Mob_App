import 'package:equatable/equatable.dart';

abstract class EducationEvent extends Equatable {
  const EducationEvent();

  @override
  List<Object?> get props => [];
}

class MobileNumberChanged_instant extends EducationEvent {
  final String mobileNumber;

  const MobileNumberChanged_instant(this.mobileNumber);

  @override
  List<Object?> get props => [mobileNumber];
}

class FetchDegree extends EducationEvent {
  const FetchDegree();
}
