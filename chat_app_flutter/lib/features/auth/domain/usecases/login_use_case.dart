import 'package:chat_app/features/auth/domain/entities/user_entity.dart';

import '../repositories/auth_repository.dart';

class LoginUseCase {

  final AuthRepository authRepository;

  LoginUseCase({required this.authRepository});

  Future<UserEntity> call(String email, String password) {
    // Gọi phương thức login từ repository
    return  authRepository.login(email, password);
  }

}