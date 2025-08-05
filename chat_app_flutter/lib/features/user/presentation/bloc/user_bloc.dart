import 'package:chat_app/features/user/domain/usecases/get_user_use_case.dart';
import 'package:chat_app/features/user/presentation/bloc/user_event.dart';
import 'package:chat_app/features/user/presentation/bloc/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/change_password_use_case.dart';
import '../../domain/usecases/update_user_use_case.dart';
import '../../domain/usecases/upload_profile_image_use_case.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final ChangePasswordUseCase changePasswordUseCase;
  final GetUserUseCase getUserUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final UploadProfileImageUseCase uploadProfileImageUseCase;

  UserBloc({
    required this.changePasswordUseCase,
    required this.getUserUseCase,
    required this.updateUserUseCase,
    required this.uploadProfileImageUseCase

  }) : super(UserInitialState()) {
    on<ChangePasswordEvent>(_onChangePassword);
    on<FetchUserEvent>(_onFetchUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<UploadProfileImageEvent>(_onUploadProfileImage);
  }

  Future<void> _onChangePassword(ChangePasswordEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());

    try {
      final success = await changePasswordUseCase(event.oldPassword, event.newPassword);

      if (success) {
        emit(ChangePasswordSuccessState(message: 'Password changed successfully.'));
      } else {
        emit(UserFailureState(error: 'Failed to change password.'));
      }
    } catch (e) {
      emit(UserFailureState(error: e.toString()));
    }
  }

  Future<void> _onUpdateUser(UpdateUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());

    try {
      final success = await updateUserUseCase(event.username, event.profileImage);

      if (success) {
        emit(UserUpdateSuccessState(message: 'Updated user successfully.'));
      } else {
        emit(UserFailureState(error: 'Failed to update user.'));
      }
    } catch (e) {
      emit(UserFailureState(error: e.toString()));
    }
  }


  Future<void> _onFetchUser(FetchUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoadingState());
    try {
      final user = await getUserUseCase();
      emit(UserLoadedState(user));
    } catch (e) {
      emit(UserFailureState(error: e.toString()));
    }
  }

  Future<void> _onUploadProfileImage(UploadProfileImageEvent event, Emitter<UserState> emit) async {
    emit(UploadImageInProgressState());

    try {
      final imageUrl = await uploadProfileImageUseCase(event.imageFile);
      emit(UploadImageSuccessState(imageUrl: imageUrl));
    } catch (e) {
      emit(UploadImageFailureState(error: e.toString()));
    }
  }
}