import 'package:chat_app/features/contact/domain/entities/contact_entity.dart';

class ContactModel extends ContactEntity {

  ContactModel({
    required super.id,
    required super.username,
    required super.email,
    required super.profileImage,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['contact_id'],
      username: json['username'],
      email: json['email'],
      profileImage: json['profile_image'] ?? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRDk_071dbbz-bewOvpfYa3IlyImYtpvQmluw&s",
    );
  }
}