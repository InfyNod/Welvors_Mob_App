import 'package:equatable/equatable.dart';

enum EducationStatus { initial, loading, success, failure }

class EducationState_instant extends Equatable {
  final String mobileNumber;
  final EducationStatus status;
  final String? errorMessage;

  const EducationState_instant({
    this.mobileNumber = '',
    this.status = EducationStatus.initial,
    this.errorMessage,
  });

  EducationState_instant copyWith({
    String? mobileNumber,
    EducationStatus? status,
    String? errorMessage,
  }) {
    return EducationState_instant(
      mobileNumber: mobileNumber ?? this.mobileNumber,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [mobileNumber, status, errorMessage];
}
