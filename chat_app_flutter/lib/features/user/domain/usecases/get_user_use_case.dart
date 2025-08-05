import 'package:chat_app/features/user/domain/entities/user_detail_entity.dart';

import '../repositories/user_repository.dart';

class GetUserUseCase {
  final UserRepository userRepository;

  GetUserUseCase({required this.userRepository});

  Future<UserDetailEntity> call() {
    return userRepository.fetchUser();
  }
}