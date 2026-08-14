import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CommitmentEvent extends Equatable {
  const CommitmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadCommitmentData extends CommitmentEvent {}

class EndExclusiveStatusRequested extends CommitmentEvent {}

class ApproveRequestEvent extends CommitmentEvent {
  final String partnerName;
  final String intent;
  final String imageUrl;
  final Color intentColor;
  final Color intentTextColor;
  final IconData intentIcon;

  const ApproveRequestEvent({
    required this.partnerName,
    required this.intent,
    required this.imageUrl,
    required this.intentColor,
    required this.intentTextColor,
    required this.intentIcon,
  });

  @override
  List<Object?> get props => [
        partnerName,
        intent,
        imageUrl,
        intentColor,
        intentTextColor,
        intentIcon,
      ];
}

class BackToManagementRequested extends CommitmentEvent {}
