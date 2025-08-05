import 'dart:io';

abstract class UserEvent {}

class ChangePasswordEvent extends UserEvent {
  final String oldPassword;
  final String newPassword;

  ChangePasswordEvent({required this.oldPassword, required this.newPassword});
}

class FetchUserEvent extends UserEvent {}

class UpdateUserEvent extends UserEvent {
  final String username;
  final String profileImage;

  UpdateUserEvent({required this.username, required this.profileImage});

}

class UploadProfileImageEvent extends UserEvent {
  final File imageFile;

  UploadProfileImageEvent({required this.imageFile});
}