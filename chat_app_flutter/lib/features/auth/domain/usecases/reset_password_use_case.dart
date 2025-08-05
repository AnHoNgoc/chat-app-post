import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {

  final AuthRepository authRepository;

  ResetPasswordUseCase({required this.authRepository});

  Future<String> call(String token, String newPassword) {
    return  authRepository.resetPassword(token, newPassword);
  }

}