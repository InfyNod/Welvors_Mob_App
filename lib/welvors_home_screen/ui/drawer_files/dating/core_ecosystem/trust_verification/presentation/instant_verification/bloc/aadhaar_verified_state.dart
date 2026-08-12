import 'package:equatable/equatable.dart';

enum AadhaarVerifiedStatus { initial, loading, success, failure }

class AadhaarVerifiedState extends Equatable {
  final AadhaarVerifiedStatus status;
  final int trustScore;
  final String? errorMessage;

  const AadhaarVerifiedState({
    this.status = AadhaarVerifiedStatus.initial,
    this.trustScore = 30,
    this.errorMessage,
  });

  AadhaarVerifiedState copyWith({
    AadhaarVerifiedStatus? status,
    int? trustScore,
    String? errorMessage,
  }) {
    return AadhaarVerifiedState(
      status: status ?? this.status,
      trustScore: trustScore ?? this.trustScore,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, trustScore, errorMessage];
}
