abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final String message;

  AuthSuccessState({required this.message});
}

class AuthFailureState extends AuthState {
  final String error;

  AuthFailureState({required this.error});
}

class ForgotPasswordLoadingState extends AuthState {}

class ForgotPasswordSuccessState extends AuthState {
  final String message;

  ForgotPasswordSuccessState({required this.message});
}

class ForgotPasswordFailureState   extends AuthState {
  final String error;

  ForgotPasswordFailureState ({required this.error});
}

class ResetPasswordLoadingState extends AuthState {}

class ResetPasswordSuccessState extends AuthState {
  final String message;

  ResetPasswordSuccessState({required this.message});
}

class ResetPasswordFailureState extends AuthState {
  final String error;

  ResetPasswordFailureState({required this.error});
}