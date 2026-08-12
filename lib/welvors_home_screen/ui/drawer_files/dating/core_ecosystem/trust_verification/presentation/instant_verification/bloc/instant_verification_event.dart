import 'package:equatable/equatable.dart';

import '../model/verification_document.dart';

abstract class InstantVerificationEvent {
  const InstantVerificationEvent();
}

abstract class ConsentEvent extends Equatable {
  const ConsentEvent();

  @override
  List<Object?> get props => [];
}

/// Select Aadhaar / PAN / Driving Licence
class SelectDocument extends InstantVerificationEvent {
  final VerificationDocument document;

  const SelectDocument(this.document);
}

/// Continue from document screen
class ContinueWithDocument extends InstantVerificationEvent {
  const ContinueWithDocument();
}

/// Mobile number changed
class MobileNumberChanged extends InstantVerificationEvent {
  final String mobileNumber;

  const MobileNumberChanged(this.mobileNumber);
}

/// Send OTP
class SendOtp extends InstantVerificationEvent {
  const SendOtp();
}

/// OTP digit changed
class OtpChanged extends InstantVerificationEvent {
  final String otp;

  const OtpChanged(this.otp);
}

/// Verify OTP
class VerifyOtp extends InstantVerificationEvent {
  const VerifyOtp();
}

/// Resend OTP
class ResendOtp extends InstantVerificationEvent {
  const ResendOtp();
}

/// Go back to previous step
class PreviousStep extends InstantVerificationEvent {
  const PreviousStep();
}

/// Toggle DigiLocker consent checkbox
class ToggleConsent extends InstantVerificationEvent {
  const ToggleConsent();
}

/// Allow DigiLocker access and verify document
class AllowAndVerify extends InstantVerificationEvent {
  const AllowAndVerify();
}

/// Deny DigiLocker consent
class DenyConsent extends InstantVerificationEvent {
  const DenyConsent();
}
