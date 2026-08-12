import 'package:equatable/equatable.dart';

enum EducationStatus { initial, loading, success, failure }

class EducationState_manually extends Equatable {
  final String mobileNumber;
  final EducationStatus status;
  final String? errorMessage;

  const EducationState_manually({
    this.mobileNumber = '',
    this.status = EducationStatus.initial,
    this.errorMessage,
  });

  EducationState_manually copyWith({
    String? mobileNumber,
    EducationStatus? status,
    String? errorMessage,
  }) {
    return EducationState_manually(
      mobileNumber: mobileNumber ?? this.mobileNumber,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [mobileNumber, status, errorMessage];
}
