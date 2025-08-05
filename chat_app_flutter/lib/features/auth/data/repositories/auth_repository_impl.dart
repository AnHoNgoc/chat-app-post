 import 'package:chat_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:chat_app/features/auth/domain/entities/user_entity.dart';
import 'package:chat_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {

  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl({required this.authRemoteDataSource});
  
  @override
  Future<UserEntity> login(String email, String password) async {
    return await authRemoteDataSource.login(email, password);
  }

  @override
  Future<bool> register(String username, String email, String password) async {
    return await authRemoteDataSource.register(username, email, password);
  }

  @override
  Future<String> forgotPassword(String email) async {
    return await authRemoteDataSource.forgotPassword(email);
  }

  @override
  Future<String> resetPassword(String token, String newPassword) {
    // TODO: implement resetPassword
    throw UnimplementedError();
  }

  @override
  Future<void> logout(String refreshToken) async {
    return await authRemoteDataSource.logout(refreshToken);
  }
}