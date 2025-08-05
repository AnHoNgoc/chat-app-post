import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/features/auth/presentation/widgets/login_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/app_validator.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_input_field.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        AuthRegisterEvent(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w), // sử dụng .w cho padding ngang
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthInputField(
                  hint: "Username",
                  icon: Icons.person,
                  controller: _usernameController,
                  validator: AppValidator.validateUsername,
                  // Giả sử AuthInputField có fontSize
                  // fontSize: 16.sp,
                ),
                SizedBox(height: 20.h), // chiều cao responsive
                AuthInputField(
                  hint: "Email",
                  icon: Icons.email,
                  controller: _emailController,
                  validator: AppValidator.validateEmail,
                  // fontSize: 16.sp,
                ),
                SizedBox(height: 20.h),
                AuthInputField(
                  hint: "Password",
                  icon: Icons.password,
                  controller: _passwordController,
                  isPassword: true,
                  validator: AppValidator.validatePassword,
                  // fontSize: 16.sp,
                ),
                SizedBox(height: 30.h),
                BlocConsumer<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return AuthButton(text: "Register", onPressed: _onRegister);
                  },
                  listener: (context, state) {
                    if (state is AuthSuccessState) {
                      Navigator.pushNamed(context, "/login");
                    } else if (state is AuthFailureState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.error)),
                      );
                    }
                  },
                ),
                SizedBox(height: 20.h),
                LoginPrompt(
                  title: "Already have an account? ",
                  subtitle: "Click here to login",
                  onTap: () {
                    Navigator.pushNamed(context, "/login");
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