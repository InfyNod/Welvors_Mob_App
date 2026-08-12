import '../model/verification_document.dart';

class InstantVerificationRepository {
  Future<bool> sendOtp({
    required VerificationDocument document,
    required String mobileNumber,
  }) async {
    // TODO: Replace with actual DigiLocker API
    await Future.delayed(const Duration(seconds: 1));

    return true;
  }

  Future<bool> verifyOtp({
    required String mobileNumber,
    required String otp,
  }) async {
    // TODO: Replace with actual DigiLocker API
    await Future.delayed(const Duration(seconds: 1));

    // Demo OTP
    return otp == '121212';
  }

  Future<bool> resendOtp({required String mobileNumber}) async {
    await Future.delayed(const Duration(seconds: 1));

    return true;
  }
}
