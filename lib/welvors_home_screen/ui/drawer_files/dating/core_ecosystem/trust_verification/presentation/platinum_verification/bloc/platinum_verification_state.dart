import 'dart:io';

import 'package:equatable/equatable.dart';

enum PlatinumStatus { initial, loading, loaded, submitting, success, failure }

class PlatinumVerificationState extends Equatable {
  final PlatinumStatus status;

  /// 0 = Payment
  /// 1 = Criminal
  /// 2 = Income
  /// 3 = Contact
  /// 4 = Success
  final int step;

  // --------------------------------------------------
  // PAYMENT
  // --------------------------------------------------

  final String paymentMethod;

  // --------------------------------------------------
  // INCOME
  // --------------------------------------------------

  final String incomeBracket;
  final String incomeProof;

  /// Selected income proof file
  final File? incomeProofFile;

  /// Selected income proof file name
  final String? incomeProofFileName;

  // --------------------------------------------------
  // RESIDENCE
  // --------------------------------------------------

  final String residenceState;

  // --------------------------------------------------
  // AUTHORIZATION / CONFIRMATION
  // --------------------------------------------------

  final bool criminalAuthorized;
  final bool incomeConfirmed;
  final bool contactConsent;

  // --------------------------------------------------
  // CONTACT
  // --------------------------------------------------

  final String contactName;
  final String relationship;
  final String contactMobile;
  final String contactEmail;

  // --------------------------------------------------
  // ERROR
  // --------------------------------------------------

  final String? errorMessage;

  const PlatinumVerificationState({
    this.status = PlatinumStatus.initial,
    this.step = 0,

    // Payment
    this.paymentMethod = 'UPI',

    // Income
    this.incomeBracket = '20–50 LPA',
    this.incomeProof = '',
    this.incomeProofFile,
    this.incomeProofFileName,

    // Residence
    this.residenceState = 'Maharashtra',

    // Authorization
    this.criminalAuthorized = false,
    this.incomeConfirmed = false,
    this.contactConsent = true,

    // Contact
    this.contactName = 'Meera Sharma',
    this.relationship = 'Mother',
    this.contactMobile = '+91 98765 43210',
    this.contactEmail = '',

    // Error
    this.errorMessage,
  });

  PlatinumVerificationState copyWith({
    PlatinumStatus? status,
    int? step,

    // Payment
    String? paymentMethod,

    // Income
    String? incomeBracket,
    String? incomeProof,
    File? incomeProofFile,
    String? incomeProofFileName,

    // Remove file
    bool clearIncomeProofFile = false,

    // Residence
    String? residenceState,

    // Authorization
    bool? criminalAuthorized,
    bool? incomeConfirmed,
    bool? contactConsent,

    // Contact
    String? contactName,
    String? relationship,
    String? contactMobile,
    String? contactEmail,

    // Error
    String? errorMessage,
  }) {
    return PlatinumVerificationState(
      status: status ?? this.status,
      step: step ?? this.step,

      // Payment
      paymentMethod: paymentMethod ?? this.paymentMethod,

      // Income
      incomeBracket: incomeBracket ?? this.incomeBracket,
      incomeProof: incomeProof ?? this.incomeProof,

      incomeProofFile: clearIncomeProofFile
          ? null
          : incomeProofFile ?? this.incomeProofFile,

      incomeProofFileName: clearIncomeProofFile
          ? null
          : incomeProofFileName ?? this.incomeProofFileName,

      // Residence
      residenceState: residenceState ?? this.residenceState,

      // Authorization
      criminalAuthorized: criminalAuthorized ?? this.criminalAuthorized,

      incomeConfirmed: incomeConfirmed ?? this.incomeConfirmed,

      contactConsent: contactConsent ?? this.contactConsent,

      // Contact
      contactName: contactName ?? this.contactName,
      relationship: relationship ?? this.relationship,
      contactMobile: contactMobile ?? this.contactMobile,
      contactEmail: contactEmail ?? this.contactEmail,

      // Error
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    step,

    // Payment
    paymentMethod,

    // Income
    incomeBracket,
    incomeProof,
    incomeProofFile,
    incomeProofFileName,

    // Residence
    residenceState,

    // Authorization
    criminalAuthorized,
    incomeConfirmed,
    contactConsent,

    // Contact
    contactName,
    relationship,
    contactMobile,
    contactEmail,

    // Error
    errorMessage,
  ];
}
