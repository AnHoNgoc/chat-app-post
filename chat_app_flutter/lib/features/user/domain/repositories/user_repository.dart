import 'dart:io';

import 'package:chat_app/features/user/domain/entities/user_detail_entity.dart';



abstract class UserRepository {
  Future<UserDetailEntity> fetchUser();
  Future<bool> changePassword(String oldPassword, String newPassword);
  Future<bool> updateUser(String username, String profileImage);
  Future<String> uploadProfileImage(File imageFile);
}