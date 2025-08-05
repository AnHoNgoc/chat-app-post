

import '../repositories/auth_repository.dart';

class LogoutUseCase {

  final AuthRepository authRepository;

  LogoutUseCase({required this.authRepository});

  Future<void> call(String refreshToken) {
    return authRepository.logout(refreshToken);
  }
}