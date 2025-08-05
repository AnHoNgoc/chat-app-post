import 'package:chat_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.email,
    required super.username,
    required super.accessToken,
    required super.refreshToken,
    required super.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user']['id'],
      email: json['user']['email'],
      username: json['user']['username'],
      profileImage: json['user']['profile_image'] ??
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDk_071dbbz-bewOvpfYa3IlyImYtpvQmluw&s",
      accessToken: json['accessToken'] ?? "",
      refreshToken: json['refreshToken'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': {
        'id': id,
        'email': email,
        'username': username,
        'profile_image': profileImage,
      },
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  @override
  String toString() {
    return 'UserModel{id: $id, email: $email, name: $username, token: $accessToken, refreshToken: $refreshToken}';
  }
}