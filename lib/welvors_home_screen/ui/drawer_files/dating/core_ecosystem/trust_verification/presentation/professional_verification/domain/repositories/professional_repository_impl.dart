import 'professional_repository.dart';

class ProfessionalRepositoryImpl implements ProfessionalRepository {
  @override
  Future<void> sendCode(String email) async {
    await Future.delayed(const Duration(seconds: 1));

    // TODO: API call
    //
    // final response = await dio.post(
    //   '/professional/send-code',
    //   data: {
    //     'email': email,
    //   },
    // );

    return;
  }

  @override
  Future<bool> verifyCode({required String email, required String code}) async {
    await Future.delayed(const Duration(seconds: 1));

    // TODO: API call
    //
    // final response = await dio.post(
    //   '/professional/verify-code',
    //   data: {
    //     'email': email,
    //     'code': code,
    //   },
    // );

    // Demo
    return code == '123456';
  }

  @override
  Future<void> resendCode(String email) async {
    await Future.delayed(const Duration(seconds: 1));

    // TODO: API call

    return;
  }
}
