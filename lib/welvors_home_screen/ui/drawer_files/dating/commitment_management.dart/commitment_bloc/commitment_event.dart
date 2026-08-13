import 'package:equatable/equatable.dart';

abstract class CommitmentEvent extends Equatable {
  const CommitmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadCommitmentData extends CommitmentEvent {}

class EndExclusiveStatusRequested extends CommitmentEvent {}

class ApproveRequestEvent extends CommitmentEvent {
  final String partnerName;
  const ApproveRequestEvent(this.partnerName);

  @override
  List<Object?> get props => [partnerName];
}
