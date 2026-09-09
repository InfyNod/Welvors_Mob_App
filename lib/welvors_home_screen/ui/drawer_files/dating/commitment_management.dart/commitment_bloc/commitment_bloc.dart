import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'commitment_event.dart';
import 'commitment_state.dart';
import '../service_commitment.dart';

class CommitmentBloc extends Bloc<CommitmentEvent, CommitmentState> {
  // Use static variables to mock persistence across screen navigations.
  static bool _isSingle = false;
  static CommitmentLoaded? _currentCommitment;
  static String? _selfImageUrl;
  static String? _selfName;

  static bool get isSingle => _isSingle;
  static CommitmentLoaded? get currentCommitment => _currentCommitment;

  static String _getFormattedCurrentDate() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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
      selfImageUrl: '',
      selfName: 'You',
      intentColor: event.intentColor,
      intentTextColor: event.intentTextColor,
      intentIcon: event.intentIcon,
      confirmationLabel: 'Mutually confirmed',
    );
    emit(_currentCommitment!);
  }

  Future<void> _onLoadCommitmentData(
    LoadCommitmentData event,
    Emitter<CommitmentState> emit,
  ) async {
    try {
      emit(CommitmentLoading());
      final data = await CommitmentApiService().getCommitmentData();

      if (data != null && data['hasCommitment'] == true) {
        final commitments = data['commitments'] as List<dynamic>? ?? [];
        if (commitments.isNotEmpty) {
          final commitment = commitments[0];
          final partner = commitment['partner'] ?? {};
          final self = commitment['self'] ?? {};
          final tagLabel = commitment['tagLabel'] ?? 'Dating';
          final confirmationLabel =
              commitment['confirmation']?['label'] ?? 'Mutually confirmed';

          Color bgColor = const Color(0xFFFDF0F3);
          Color textColor = const Color(0xFFC73A5E);
          IconData icon = Icons.favorite_border;

          if (tagLabel.toLowerCase().contains('open')) {
            bgColor = const Color(0xFFE8F5E9);
            textColor = const Color(0xFF2E7D32);
            icon = Icons.all_inclusive;
          } else if (tagLabel.toLowerCase().contains('marry') ||
              tagLabel.toLowerCase().contains('marriage')) {
            bgColor = const Color(0xFFFDF6E3);
            textColor = const Color(0xFF9E6B17);
            icon = Icons.diamond_outlined;
          }

          _selfImageUrl = self['photo'];
          _selfName = self['firstName'];

          _currentCommitment = CommitmentLoaded(
            partnerName: partner['firstName'] ?? 'Partner',
            duration: commitment['sinceLabel'] ?? _getFormattedCurrentDate(),
            intent: tagLabel,
            isIdentityVerified: partner['identityVerified'] == true,
            imageUrl: partner['photo'] ?? '',
            selfImageUrl: _selfImageUrl ?? '',
            selfName: _selfName ?? 'You',
            intentColor: bgColor,
            intentTextColor: textColor,
            intentIcon: icon,
            confirmationLabel: confirmationLabel,
          );
          _isSingle = false;
          emit(_currentCommitment!);
          return;
        }
      }

      _isSingle = true;
      _currentCommitment = null;

      // Fallback for self image if single, since we don't have the API single response structure
      String selfImg = _selfImageUrl ?? '';
      String selfNm = _selfName ?? 'You';
      
      if (data != null && data['data'] != null && data['data']['self'] != null) {
        selfImg = data['data']['self']['photo'] ?? selfImg;
        selfNm = data['data']['self']['firstName'] ?? selfNm;
        _selfImageUrl = selfImg;
        _selfName = selfNm;
      }
      emit(CommitmentSingle(selfImageUrl: selfImg, selfName: selfNm));
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
      emit(
        CommitmentEnded(
          partnerName: currentState.partnerName,
          userName: currentState.selfName,
        ),
      );
    }
  }

  Future<void> _onBackToManagementRequested(
    BackToManagementRequested event,
    Emitter<CommitmentState> emit,
  ) async {
    _isSingle = true; // Mock saving the state to backend
    _currentCommitment = null;
    emit(
      CommitmentSingle(
        selfImageUrl: _selfImageUrl ?? '',
        selfName: _selfName ?? 'You',
      ),
    );
  }
}
