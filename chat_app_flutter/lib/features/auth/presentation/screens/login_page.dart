import 'package:chat_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:chat_app/features/auth/presentation/widgets/login_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../theme_cubit.dart';
import '../../../../utils/app_validator.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_input_field.dart';
import '../widgets/forgot_password.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(AuthLoginEvent(
        email: _emailController.text,
        password: _passwordController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Switch.adaptive(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                context.read<ThemeCubit>().toggleTheme();
              },
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthInputField(
                  hint: "Email",
                  icon: Icons.email,
                  iconSize: 24.w,               // thêm iconSize responsive
                  controller: _emailController,
                  validator: AppValidator.validateEmail,
                ),
                SizedBox(height: 20.h),
                AuthInputField(
                  hint: "Password",
                  icon: Icons.password,
                  iconSize: 24.w,               // thêm iconSize responsive
                  controller: _passwordController,
                  isPassword: true,
                  validator: AppValidator.validatePassword,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      final message = await showDialog<String>(
                        context: context,
                        builder: (context) => BlocProvider.value(
                          value: context.read<AuthBloc>(),
                          child: ForgotPasswordDialog(),
                        ),
                      );

                      if (message != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      }
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(fontSize: 14.sp, color: Colors.blue), // responsive font
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                BlocConsumer<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoadingState) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return AuthButton(
                      text: "Login",
                      onPressed: _onLogin,
                    );
                  },
                  listener: (context, state) {
                    if (state is AuthSuccessState) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/conversations-page", (route) => false);
                    } else if (state is AuthFailureState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 20.h),
                LoginPrompt(
                  title: "If you don't have account? ",
                  subtitle: "Click here to register",
                  onTap: () {
                    Navigator.pushNamed(context, "/register");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
