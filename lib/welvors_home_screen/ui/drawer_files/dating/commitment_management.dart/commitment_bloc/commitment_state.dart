import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
  final String imageUrl;
  final String selfImageUrl;
  final String selfName;
  final Color intentColor;
  final Color intentTextColor;
  final IconData intentIcon;
  final String confirmationLabel;
  final String relationshipId;

  const CommitmentLoaded({
    required this.partnerName,
    required this.duration,
    required this.intent,
    required this.isIdentityVerified,
    required this.imageUrl,
    required this.selfImageUrl,
    required this.selfName,
    required this.intentColor,
    required this.intentTextColor,
    required this.intentIcon,
    required this.confirmationLabel,
    required this.relationshipId,
  });

  @override
  List<Object?> get props => [
        partnerName,
        duration,
        intent,
        isIdentityVerified,
        imageUrl,
        selfImageUrl,
        selfName,
        intentColor,
        intentTextColor,
        intentIcon,
        confirmationLabel,
        relationshipId,
      ];
}

class CommitmentError extends CommitmentState {
  final String message;

  const CommitmentError(this.message);

  @override
  List<Object?> get props => [message];
}

class CommitmentEndingSplash extends CommitmentState {}

class CommitmentEnded extends CommitmentState {
  final String partnerName;
  final String userName;

  const CommitmentEnded({
    required this.partnerName,
    required this.userName,
  });

  @override
  List<Object?> get props => [partnerName, userName];
}

class CommitmentSingle extends CommitmentState {
  final String selfImageUrl;
  final String selfName;

  const CommitmentSingle({required this.selfImageUrl, required this.selfName});

  @override
  List<Object?> get props => [selfImageUrl, selfName];
}

