import 'package:chat_app/features/user/domain/entities/user_detail_entity.dart';

class UserDetailModel extends UserDetailEntity {

  UserDetailModel({
    required super.email,
    required super.username,
    required super.profileImage,
  });

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      email: json['email'] ?? "",
      username: json['username']?? "",
      profileImage: json['profile_image'] ?? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDk_071dbbz-bewOvpfYa3IlyImYtpvQmluw&s"
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'profile_image': profileImage,
    };
  }

  @override
  String toString() {
    return 'UserModel{ email: $email, name: $username,profile_image: $profileImage }';
  }
}