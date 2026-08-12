abstract class ProfessionalRepository {
  Future<void> sendCode(String email);

  Future<bool> verifyCode({required String email, required String code});

  Future<void> resendCode(String email);
}
