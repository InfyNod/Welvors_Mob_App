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
  final Color intentColor;
  final Color intentTextColor;
  final IconData intentIcon;

  const CommitmentLoaded({
    required this.partnerName,
    required this.duration,
    required this.intent,
    required this.isIdentityVerified,
    required this.imageUrl,
    required this.intentColor,
    required this.intentTextColor,
    required this.intentIcon,
  });

  @override
  List<Object?> get props => [
        partnerName,
        duration,
        intent,
        isIdentityVerified,
        imageUrl,
        intentColor,
        intentTextColor,
        intentIcon,
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

class CommitmentSingle extends CommitmentState {}

