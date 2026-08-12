import 'package:equatable/equatable.dart';

abstract class PlatinumVerificationEvent extends Equatable {
  const PlatinumVerificationEvent();

  @override
  List<Object?> get props => [];
}

// --------------------------------------------------
// LOAD
// --------------------------------------------------

class LoadPlatinumVerification extends PlatinumVerificationEvent {}

// --------------------------------------------------
// PAYMENT
// --------------------------------------------------

class SelectPaymentMethod extends PlatinumVerificationEvent {
  final String method;

  const SelectPaymentMethod(this.method);

  @override
  List<Object?> get props => [method];
}

// --------------------------------------------------
// INCOME BRACKET
// --------------------------------------------------

class SelectIncomeBracket extends PlatinumVerificationEvent {
  final String bracket;

  const SelectIncomeBracket(this.bracket);

  @override
  List<Object?> get props => [bracket];
}

// --------------------------------------------------
// INCOME PROOF
// --------------------------------------------------

class SelectIncomeProof extends PlatinumVerificationEvent {
  final String proof;

  const SelectIncomeProof(this.proof);

  @override
  List<Object?> get props => [proof];
}

// --------------------------------------------------
// INCOME PROOF FILE
// --------------------------------------------------

class PickIncomeProofFile extends PlatinumVerificationEvent {}

class RemoveIncomeProofFile extends PlatinumVerificationEvent {}

// --------------------------------------------------
// INCOME CONFIRMATION
// --------------------------------------------------

class SetIncomeConfirmation extends PlatinumVerificationEvent {
  final bool value;

  const SetIncomeConfirmation(this.value);

  @override
  List<Object?> get props => [value];
}

// --------------------------------------------------
// CRIMINAL BACKGROUND
// --------------------------------------------------

class SetCriminalAuthorization extends PlatinumVerificationEvent {
  final bool value;

  const SetCriminalAuthorization(this.value);

  @override
  List<Object?> get props => [value];
}

class SubmitCriminalBackground extends PlatinumVerificationEvent {}

// --------------------------------------------------
// CONTACT CONSENT
// --------------------------------------------------

class SetContactConsent extends PlatinumVerificationEvent {
  final bool value;

  const SetContactConsent(this.value);

  @override
  List<Object?> get props => [value];
}

// --------------------------------------------------
// RESIDENCE STATE
// --------------------------------------------------

class UpdateResidenceState extends PlatinumVerificationEvent {
  final String value;

  const UpdateResidenceState(this.value);

  @override
  List<Object?> get props => [value];
}

// --------------------------------------------------
// CONTACT NAME
// --------------------------------------------------

class UpdateContactName extends PlatinumVerificationEvent {
  final String value;

  const UpdateContactName(this.value);

  @override
  List<Object?> get props => [value];
}

// --------------------------------------------------
// RELATIONSHIP
// --------------------------------------------------

class UpdateRelationship extends PlatinumVerificationEvent {
  final String value;

  const UpdateRelationship(this.value);

  @override
  List<Object?> get props => [value];
}

// --------------------------------------------------
// CONTACT MOBILE
// --------------------------------------------------

class UpdateContactMobile extends PlatinumVerificationEvent {
  final String value;

  const UpdateContactMobile(this.value);

  @override
  List<Object?> get props => [value];
}

// --------------------------------------------------
// CONTACT EMAIL
// --------------------------------------------------

class UpdateContactEmail extends PlatinumVerificationEvent {
  final String value;

  const UpdateContactEmail(this.value);

  @override
  List<Object?> get props => [value];
}

// --------------------------------------------------
// STEP
// --------------------------------------------------

class GoToStep extends PlatinumVerificationEvent {
  final int step;

  const GoToStep(this.step);

  @override
  List<Object?> get props => [step];
}

class SubmitCurrentStep extends PlatinumVerificationEvent {}

// --------------------------------------------------
// VERIFICATION
// --------------------------------------------------

class StartVerification extends PlatinumVerificationEvent {}

// --------------------------------------------------
// SAVE
// --------------------------------------------------

class SaveForLater extends PlatinumVerificationEvent {}
