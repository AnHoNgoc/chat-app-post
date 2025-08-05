import 'dart:io';

import '../repositories/user_repository.dart';

class UploadProfileImageUseCase {
  final UserRepository userRepository;

  UploadProfileImageUseCase({required this.userRepository});

  Future<String> call(File imageFile) {
    return userRepository.uploadProfileImage(imageFile);
  }
}