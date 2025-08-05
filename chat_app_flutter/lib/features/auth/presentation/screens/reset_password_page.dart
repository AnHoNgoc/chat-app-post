import 'package:chat_app/utils/app_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_input_field.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;
  const ResetPasswordPage({super.key, required this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      ResetPasswordEvent(
        token: widget.token,
        newPassword: _passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ResetPasswordSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is ResetPasswordFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Reset Password",
            style: TextStyle(fontSize: 20.sp), // font responsive
          ),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 24.w), // icon responsive
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w), // padding responsive
          child: Column(
            children: [
              SizedBox(height: 100.h),
              Center(
                child: Text(
                  "Please reset your password",
                  style: TextStyle(
                    fontSize: 25.sp, // font responsive
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 100.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AuthInputField(
                          controller: _passwordController,
                          hint: "New Password",
                          isPassword: true,
                          icon: Icons.lock,
                          validator: AppValidator.validatePassword,
                          // Nếu AuthInputField hỗ trợ fontSize thì truyền 16.sp
                          // fontSize: 16.sp,
                        ),
                        SizedBox(height: 16.h),
                        AuthInputField(
                          controller: _confirmPasswordController,
                          hint: "Confirm New Password",
                          isPassword: true,
                          icon: Icons.lock_outline,
                          validator: (value) =>
                              AppValidator.validateConfirmPassword(value, _passwordController.text),
                          // fontSize: 16.sp,
                        ),
                        SizedBox(height: 25.h),
                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: Text(
                              "Reset Password",
                              style: TextStyle(fontSize: 18.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}