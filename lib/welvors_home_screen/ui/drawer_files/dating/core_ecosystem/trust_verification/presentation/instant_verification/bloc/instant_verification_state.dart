import '../model/verification_document.dart';

enum InstantVerificationStatus {
  initial,
  loading,
  success,
  failure,
  aadhaarVerified,
}

class InstantVerificationState {
  final int currentStep;
  final VerificationDocument? selectedDocument;
  final String mobileNumber;
  final String otp;
  final int resendSeconds;
  final bool canResend;
  final bool consentAccepted;
  final bool verificationCompleted;
  final InstantVerificationStatus status;
  final String? errorMessage;

  const InstantVerificationState({
    this.currentStep = 1,

    this.selectedDocument = const VerificationDocument(
      type: VerificationDocumentType.aadhaar,
      title: 'Aadhaar Card',
      subtitle: 'Verify using your Aadhaar card',
      icon: '🪪',
      recommended: true,
    ),

    this.mobileNumber = '',
    this.otp = '',
    this.resendSeconds = 16,
    this.canResend = false,
    this.consentAccepted = false,
    this.verificationCompleted = false,
    this.status = InstantVerificationStatus.initial,
    this.errorMessage,
  });

  InstantVerificationState copyWith({
    int? currentStep,
    VerificationDocument? selectedDocument,
    String? mobileNumber,
    String? otp,
    int? resendSeconds,
    bool? canResend,
    bool? consentAccepted,
    bool? verificationCompleted,
    InstantVerificationStatus? status,
    String? errorMessage,
  }) {
    return InstantVerificationState(
      currentStep: currentStep ?? this.currentStep,
      selectedDocument: selectedDocument ?? this.selectedDocument,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      otp: otp ?? this.otp,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      canResend: canResend ?? this.canResend,
      consentAccepted: consentAccepted ?? this.consentAccepted,
      verificationCompleted:
          verificationCompleted ?? this.verificationCompleted,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}
