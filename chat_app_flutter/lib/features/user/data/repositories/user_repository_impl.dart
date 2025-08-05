import 'dart:io';

import 'package:chat_app/features/user/data/datasources/user_remote_data_source.dart';
import 'package:chat_app/features/user/domain/entities/user_detail_entity.dart';
import 'package:chat_app/features/user/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {

  final UserRemoteDataSource userRemoteDataSource;

  UserRepositoryImpl({required this.userRemoteDataSource});

  @override
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    return await userRemoteDataSource.changePassword(oldPassword, newPassword);
  }

  @override
  Future<UserDetailEntity> fetchUser() async {
    return await userRemoteDataSource.fetchUser();
  }

  @override
  Future<bool> updateUser(String username, String profileImage) async {
    return await userRemoteDataSource.updateUser(username, profileImage);
  }

  @override
  Future<String> uploadProfileImage(File imageFile) async {
    return await userRemoteDataSource.uploadProfileImage(imageFile);
  }


}