import 'package:bloc/bloc.dart';
import 'package:chat_app/features/auth/domain/usecases/logout_use_case.dart';
import 'package:chat_app/features/auth/domain/usecases/reset_password_use_case.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../api/firebase_api.dart';
import '../../domain/usecases/forgot_password_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import 'auth_event.dart';
import 'auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final _storage = FlutterSecureStorage();

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
  }) : super(AuthInitialState()){
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
  }

  Future<void> _onRegister(AuthRegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final isSuccess = await registerUseCase.call(event.username, event.email, event.password);

      if (isSuccess) {
        emit(AuthSuccessState(message: 'Register Successful'));
      } else {
        emit(AuthFailureState(error: 'Register failed'));
      }
    } catch (e) {
      emit(AuthFailureState(error: e.toString()));
    }
  }

  // Xử lý sự kiện đăng nhập
  Future<void> _onLogin(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {

      final user = await loginUseCase.call(event.email, event.password);
      await _storage.write(key: "accessToken", value: user.accessToken);
      await _storage.write(key: "refreshToken", value: user.refreshToken);
      await _storage.write(key: "userId", value: user.id);
      await FirebaseApi().initNotifications();
      emit(AuthSuccessState(message: 'Login Successful'));
    } catch (e) {
      emit(AuthFailureState(error: "Username or password is incorrect"));
    }
  }

  Future<void> _onLogout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    try {
      final refreshToken = await _storage.read(key: "refreshToken");

      if (refreshToken != null) {
        await logoutUseCase.call(refreshToken);
      }

      await _storage.delete(key: "accessToken");
      await _storage.delete(key: "refreshToken");
      await _storage.delete(key: "userId");

      emit(AuthInitialState());
    } catch (e) {
      emit(AuthFailureState(error: e.toString()));
    }
  }


  Future<void> _onForgotPassword(ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    emit(ForgotPasswordLoadingState());
    try {
      final message = await forgotPasswordUseCase.call(event.email);
      emit(ForgotPasswordSuccessState(message: message));
    } catch (e) {
      emit(ForgotPasswordFailureState (error: e.toString()));
    }
  }


  Future<void> _onResetPassword(ResetPasswordEvent event, Emitter<AuthState> emit) async {
    emit(ForgotPasswordLoadingState());
    try {
      final message = await resetPasswordUseCase.call(event.token, event.newPassword);
      emit(ForgotPasswordSuccessState(message: message));
    } catch (e) {
      emit(ForgotPasswordFailureState (error: e.toString()));
    }
  }

}