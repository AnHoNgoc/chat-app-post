import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {

  final AuthRepository authRepository;

  ForgotPasswordUseCase({required this.authRepository});

  Future<String> call(String email) {
    // Gọi phương thức login từ repository
    return  authRepository.forgotPassword(email);
  }

}