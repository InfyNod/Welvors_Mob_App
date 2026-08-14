import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'commitment_event.dart';
import 'commitment_state.dart';

class CommitmentBloc extends Bloc<CommitmentEvent, CommitmentState> {
  CommitmentBloc() : super(CommitmentInitial()) {
    on<LoadCommitmentData>(_onLoadCommitmentData);
    on<EndExclusiveStatusRequested>(_onEndExclusiveStatusRequested);
    on<ApproveRequestEvent>(_onApproveRequestEvent);
    on<BackToManagementRequested>(_onBackToManagementRequested);
  }

  Future<void> _onApproveRequestEvent(
    ApproveRequestEvent event,
    Emitter<CommitmentState> emit,
  ) async {
    emit(CommitmentLoaded(
      partnerName: event.partnerName,
      duration: '12 Jun', // Use a default or current date
      intent: event.intent,
      isIdentityVerified: true,
      imageUrl: event.imageUrl,
      intentColor: event.intentColor,
      intentTextColor: event.intentTextColor,
      intentIcon: event.intentIcon,
    ));
  }

  Future<void> _onLoadCommitmentData(
    LoadCommitmentData event,
    Emitter<CommitmentState> emit,
  ) async {
    try {
      // Default initial data
      emit(CommitmentLoaded(
        partnerName: 'Priya',
        duration: '12 Jun',
        intent: 'Dating to marry',
        isIdentityVerified: true,
        imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
        intentColor: const Color(0xFFFDF6E3),
        intentTextColor: const Color(0xFF9E6B17),
        intentIcon: Icons.diamond_outlined,
      ));
    } catch (e) {
      emit(CommitmentError(e.toString()));
    }
  }

  Future<void> _onEndExclusiveStatusRequested(
    EndExclusiveStatusRequested event,
    Emitter<CommitmentState> emit,
  ) async {
    final currentState = state;
    if (currentState is CommitmentLoaded) {
      emit(CommitmentEndingSplash());
      await Future.delayed(const Duration(milliseconds: 5000));
      emit(CommitmentEnded(
        partnerName: currentState.partnerName,
        userName: 'Rahul', // Replace with dynamic user logic if available
      ));
    }
  }

  Future<void> _onBackToManagementRequested(
    BackToManagementRequested event,
    Emitter<CommitmentState> emit,
  ) async {
    emit(CommitmentSingle());
  }
}
