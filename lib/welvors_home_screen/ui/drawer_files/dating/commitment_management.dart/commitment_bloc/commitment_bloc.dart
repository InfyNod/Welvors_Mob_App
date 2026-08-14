import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'commitment_event.dart';
import 'commitment_state.dart';

class CommitmentBloc extends Bloc<CommitmentEvent, CommitmentState> {
  // Use static variables to mock persistence across screen navigations.
  static bool _isSingle = false;
  static CommitmentLoaded? _currentCommitment;

  static String _getFormattedCurrentDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${now.day} ${months[now.month - 1]}';
  }

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
    _isSingle = false; // Reset to active commitment
    _currentCommitment = CommitmentLoaded(
      partnerName: event.partnerName,
      duration: _getFormattedCurrentDate(), // dynamic date
      intent: event.intent,
      isIdentityVerified: true,
      imageUrl: event.imageUrl,
      intentColor: event.intentColor,
      intentTextColor: event.intentTextColor,
      intentIcon: event.intentIcon,
    );
    emit(_currentCommitment!);
  }

  Future<void> _onLoadCommitmentData(
    LoadCommitmentData event,
    Emitter<CommitmentState> emit,
  ) async {
    try {
      if (_isSingle) {
        emit(CommitmentSingle());
        return;
      }

      if (_currentCommitment == null) {
        // Default initial data
        _currentCommitment = CommitmentLoaded(
          partnerName: 'Priya',
          duration: _getFormattedCurrentDate(), // dynamic date
          intent: 'Dating to marry',
          isIdentityVerified: true,
          imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
          intentColor: const Color(0xFFFDF6E3),
          intentTextColor: const Color(0xFF9E6B17),
          intentIcon: Icons.diamond_outlined,
        );
      }
      
      emit(_currentCommitment!);
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
    _isSingle = true; // Mock saving the state to backend
    _currentCommitment = null;
    emit(CommitmentSingle());
  }
}
