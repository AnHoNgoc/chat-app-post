import 'package:chat_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<bool> register(String username, String email, String password);
  Future<String> forgotPassword(String email);
  Future<String> resetPassword(String token, String newPassword);
  Future<void> logout(String refreshToken);
}