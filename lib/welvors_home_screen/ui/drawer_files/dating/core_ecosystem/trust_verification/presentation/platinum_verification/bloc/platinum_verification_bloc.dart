import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/platinum_verification_repository.dart';
import 'platinum_verification_event.dart';
import 'platinum_verification_state.dart';

class PlatinumVerificationBloc
    extends Bloc<PlatinumVerificationEvent, PlatinumVerificationState> {
  final PlatinumVerificationRepository repository;

  PlatinumVerificationBloc({required this.repository})
    : super(const PlatinumVerificationState()) {
    // --------------------------------------------------
    // Load
    // --------------------------------------------------

    on<LoadPlatinumVerification>(_onLoad);

    // --------------------------------------------------
    // Payment
    // --------------------------------------------------

    on<SelectPaymentMethod>(_onPaymentMethod);

    // --------------------------------------------------
    // Income
    // --------------------------------------------------

    on<SelectIncomeBracket>(_onIncomeBracket);
    on<SelectIncomeProof>(_onIncomeProof);

    // Income Proof File
    on<PickIncomeProofFile>(_onPickIncomeProofFile);
    on<RemoveIncomeProofFile>(_onRemoveIncomeProofFile);

    // --------------------------------------------------
    // Criminal Background
    // --------------------------------------------------

    on<SetCriminalAuthorization>(_onCriminalAuthorization);

    // --------------------------------------------------
    // Income Confirmation
    // --------------------------------------------------

    on<SetIncomeConfirmation>(_onIncomeConfirmation);

    // --------------------------------------------------
    // Contact
    // --------------------------------------------------

    on<SetContactConsent>(_onContactConsent);
    on<UpdateResidenceState>(_onResidenceState);
    on<UpdateContactName>(_onContactName);
    on<UpdateRelationship>(_onRelationship);
    on<UpdateContactMobile>(_onContactMobile);
    on<UpdateContactEmail>(_onContactEmail);

    // --------------------------------------------------
    // Step
    // --------------------------------------------------

    on<GoToStep>(_onGoToStep);
    on<SubmitCurrentStep>(_onSubmitCurrentStep);

    // --------------------------------------------------
    // Verification
    // --------------------------------------------------

    on<StartVerification>(_onStartVerification);

    // --------------------------------------------------
    // Save
    // --------------------------------------------------

    on<SaveForLater>(_onSaveForLater);
  }

  // --------------------------------------------------
  // LOAD
  // --------------------------------------------------

  Future<void> _onLoad(
    LoadPlatinumVerification event,
    Emitter<PlatinumVerificationState> emit,
  ) async {
    emit(state.copyWith(status: PlatinumStatus.loading));

    try {
      final data = await repository.getInitialData();

      emit(
        state.copyWith(
          status: PlatinumStatus.loaded,
          paymentMethod: data.paymentMethod,
          incomeBracket: data.incomeBracket,
          residenceState: data.residenceState,
          contactName: data.contactName,
          relationship: data.relationship,
          contactMobile: data.contactMobile,
          contactConsent: data.contactConsent,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PlatinumStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // --------------------------------------------------
  // PAYMENT
  // --------------------------------------------------

  void _onPaymentMethod(
    SelectPaymentMethod event,
    Emitter<PlatinumVerificationState> emit,
  ) {
    emit(state.copyWith(paymentMethod: event.method));
  }

  // --------------------------------------------------
  // INCOME BRACKET
  // --------------------------------------------------

  void _onIncomeBracket(
    SelectIncomeBracket event,
    Emitter<PlatinumVerificationState> emit,
  ) {
    emit(state.copyWith(incomeBracket: event.bracket));
  }

  // --------------------------------------------------
  // INCOME PROOF
  // --------------------------------------------------

  void _onIncomeProof(
    SelectIncomeProof event,
    Emitter<PlatinumVerificationState> emit,
  ) {
    emit(state.copyWith(incomeProof: event.proof));
  }

  // --------------------------------------------------
  // PICK INCOME PROOF FILE
  // --------------------------------------------------

  Future<void> _onPickIncomeProofFile(
    PickIncomeProofFile event,
    Emitter<PlatinumVerificationState> emit,
  ) async {
    try {
      emit(state.copyWith(status: PlatinumStatus.submitting));

      final file = await repository.pickIncomeProofFile();

      // User cancelled picker
      if (file == null) {
        emit(state.copyWith(status: PlatinumStatus.loaded));

        return;
      }

      final fileName = file.path.split(Platform.pathSeparator).last;

      emit(
        state.copyWith(
          status: PlatinumStatus.loaded,
          incomeProofFile: file,
          incomeProofFileName: fileName,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PlatinumStatus.failure,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  // --------------------------------------------------
  // REMOVE INCOME PROOF FILE
  // --------------------------------------------------

  void _onRemoveIncomeProofFile(
    RemoveIncomeProofFile event,
    Emitter<PlatinumVerificationState> emit,
  ) {
    emit(
      state.copyWith(
        status: PlatinumStatus.loaded,
        incomeProofFile: null,
        incomeProofFileName: null,
        clearIncomeProofFile: true,
      ),
    );
  }

  // --------------------------------------------------
  // CRIMINAL AUTHORIZATION
  // --------------------------------------------------

  void _onCriminalAuthorization(
    SetCriminalAuthorization event,
    Emitter<PlatinumVerificationState> emit,
  ) {
    emit(state.copyWith(criminalAuthorized: event.value));
  }

  // --------------------------------------------------
  // INCOME CONFIRMATION
  // --------------------------------------------------

  void _onIncomeConfirmation(
    SetIncomeConfirmation event,
    Emitter<PlatinumVerificationState> emit,
  ) {
    emit(state.copyWith(incomeConfirmed: event.value));
  }

  // --------------------------------------------------
  // CONTACT CONSENT
  // --------------------------------------------------

  void _onContactConsent(
    SetContactConsent event,
    Emitter<PlatinumVerificationState> emit,
  ) {
    emit(state.copyWith(contactConsent: event.value));
  }

  // --------------------------------------------------
  // RESIDENCE STATE
  // --------------------------------------------------

  void _onResidenceState(
    UpdateResidenceState event,
    Emitter<PlatinumVerificationState> emit,
  ) {
    emit(state.copyWith(residenceState: event.value));
  }

  // --------------------------------------------------
  // CONTACT NAME
  // --------------------------------------------------

  void _onContactName(
    UpdateContactName event,
    Emitter<PlatinumVerificationState> emit,
  ) {
    emit(state.copyWith(contactName: event.value));
  }

  // --------------------------------------------------
  // RELATIONSHIP
  // --------------------------------------------------

  void _onRelationship(
    UpdateRelationship event,
    Emitter<PlatinumVerificationState> emit,
  ) {
    emit(state.copyWith(relationship: event.value));
  }

  // --------------------------------------------------
  // CONTACT MOBILE
  // --------------------------------------------------

  void _onContactMobile(
    UpdateContactMobile event,
    Emitter<PlatinumVerificationState> emit,
  ) {
    emit(state.copyWith(contactMobile: event.value));
  }

  // --------------------------------------------------
  // CONTACT EMAIL
  // --------------------------------------------------

  void _onContactEmail(
    UpdateContactEmail event,
    Emitter<PlatinumVerificationState> emit,
  ) {
    emit(state.copyWith(contactEmail: event.value));
  }

  // --------------------------------------------------
  // GO TO STEP
  // --------------------------------------------------

  void _onGoToStep(GoToStep event, Emitter<PlatinumVerificationState> emit) {
    emit(state.copyWith(step: event.step.clamp(0, 4)));
  }

  // --------------------------------------------------
  // SUBMIT CURRENT STEP
  // --------------------------------------------------

  void _onSubmitCurrentStep(
    SubmitCurrentStep event,
    Emitter<PlatinumVerificationState> emit,
  ) {
    // Criminal Background
    if (state.step == 1 && !state.criminalAuthorized) {
      return;
    }

    // Income
    if (state.step == 2 && !state.incomeConfirmed) {
      return;
    }

    // Move to next step
    if (state.step < 4) {
      emit(state.copyWith(step: state.step + 1));
    }
  }

  // --------------------------------------------------
  // START VERIFICATION / PAYMENT
  // --------------------------------------------------

  Future<void> _onStartVerification(
    StartVerification event,
    Emitter<PlatinumVerificationState> emit,
  ) async {
    if (state.paymentMethod.isEmpty) {
      return;
    }

    emit(state.copyWith(status: PlatinumStatus.submitting));

    try {
      await repository.startPayment(paymentMethod: state.paymentMethod);

      emit(state.copyWith(status: PlatinumStatus.success, step: 1));
    } catch (e) {
      emit(
        state.copyWith(
          status: PlatinumStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  // --------------------------------------------------
  // SAVE FOR LATER
  // --------------------------------------------------

  Future<void> _onSaveForLater(
    SaveForLater event,
    Emitter<PlatinumVerificationState> emit,
  ) async {
    await repository.saveForLater(state);
  }
}
