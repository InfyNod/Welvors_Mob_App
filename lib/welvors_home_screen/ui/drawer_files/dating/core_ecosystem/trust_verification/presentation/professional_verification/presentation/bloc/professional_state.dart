import 'package:equatable/equatable.dart';

enum ProfessionalStatus {
  initial,
  loading,
  codeSent,
  verifying,
  success,
  failure,
}

class ProfessionalState extends Equatable {
  final ProfessionalStatus status;
  final String email;
  final String code;
  final String? error;
  final int resendSeconds;

  const ProfessionalState({
    this.status = ProfessionalStatus.initial,
    this.email = '',
    this.code = '',
    this.error,
    this.resendSeconds = 0,
  });

  ProfessionalState copyWith({
    ProfessionalStatus? status,
    String? email,
    String? code,
    String? error,
    int? resendSeconds,
    bool clearError = false,
  }) {
    return ProfessionalState(
      status: status ?? this.status,
      email: email ?? this.email,
      code: code ?? this.code,
      error: clearError ? null : error ?? this.error,
      resendSeconds: resendSeconds ?? this.resendSeconds,
    );
  }

  @override
  List<Object?> get props => [status, email, code, error, resendSeconds];
}
