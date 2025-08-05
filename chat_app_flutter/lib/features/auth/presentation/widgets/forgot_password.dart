
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../utils/app_validator.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    context.read<AuthBloc>().add(ForgotPasswordEvent(email: email));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccessState) {
          Navigator.of(context).pop(state.message);
        } else if (state is ForgotPasswordFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: AlertDialog(
        title: Text(
          "Forgot Password",
          style: TextStyle(fontSize: 20.sp),
        ),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: "Enter your email",
              labelStyle: TextStyle(fontSize: 16.sp),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
            ),
            validator: AppValidator.validateEmail,
            style: TextStyle(fontSize: 16.sp),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(fontSize: 16.sp),
            ),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is ForgotPasswordLoadingState;
              return ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
                  minimumSize: Size(80.w, 36.h),
                ),
                child: isLoading
                    ? SizedBox(
                  width: 18.w,
                  height: 18.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(
                  "Send",
                  style: TextStyle(fontSize: 16.sp),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
