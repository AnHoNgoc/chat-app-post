
import 'package:chat_app/features/user/domain/repositories/user_repository.dart';

class ChangePasswordUseCase {
  final UserRepository userRepository;

  ChangePasswordUseCase({required this.userRepository});

  Future<bool> call(String oldPassword, String newPassword) {
    return userRepository.changePassword(oldPassword, newPassword);
  }
}