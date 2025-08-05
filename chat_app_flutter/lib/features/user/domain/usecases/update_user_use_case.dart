import '../repositories/user_repository.dart';

class UpdateUserUseCase {
  final UserRepository userRepository;

  UpdateUserUseCase({required this.userRepository});

  Future<bool> call(String username, String profileImage) {
    return userRepository.updateUser(username, profileImage);
  }
}