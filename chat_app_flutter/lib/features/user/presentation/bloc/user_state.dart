import 'package:chat_app/features/user/domain/entities/user_detail_entity.dart';

abstract class UserState {}

class UserInitialState extends UserState {}

class UserLoadingState extends UserState {}


class ChangePasswordSuccessState extends UserState {
  final String message;

  ChangePasswordSuccessState({required this.message});
}

class UserLoadedState extends UserState {
  final UserDetailEntity user;

  UserLoadedState(this.user);
}

class UserUpdateSuccessState extends UserState {
  final String message;

  UserUpdateSuccessState({required this.message});
}

class UserFailureState extends UserState {
  final String error;

  UserFailureState({required this.error});
}


class UploadImageInProgressState extends UserState {}

class UploadImageSuccessState extends UserState {
  final String imageUrl;

  UploadImageSuccessState({required this.imageUrl});
}

class UploadImageFailureState extends UserState {
  final String error;

  UploadImageFailureState({required this.error});
}