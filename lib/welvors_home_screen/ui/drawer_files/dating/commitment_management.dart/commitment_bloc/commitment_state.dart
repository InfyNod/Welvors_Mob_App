import 'package:equatable/equatable.dart';

abstract class CommitmentState extends Equatable {
  const CommitmentState();
  
  @override
  List<Object?> get props => [];
}

class CommitmentInitial extends CommitmentState {}

class CommitmentLoading extends CommitmentState {}

class CommitmentLoaded extends CommitmentState {
  final String partnerName;
  final String duration;
  final String intent;
  final bool isIdentityVerified;

  const CommitmentLoaded({
    required this.partnerName,
    required this.duration,
    required this.intent,
    required this.isIdentityVerified,
  });

  @override
  List<Object?> get props => [partnerName, duration, intent, isIdentityVerified];
}

class CommitmentError extends CommitmentState {
  final String message;

  const CommitmentError(this.message);

  @override
  List<Object?> get props => [message];
}
