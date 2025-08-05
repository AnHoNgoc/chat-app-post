import 'package:flutter/material.dart';

import '../../../../utils/app_validator.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop({
        'oldPassword': _oldPasswordController.text,
        'newPassword': _newPasswordController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Change Password',
        style: TextStyle(fontSize: 20.sp),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Old password
              TextFormField(
                controller: _oldPasswordController,
                obscureText: _obscureOld,
                decoration: InputDecoration(
                  labelText: 'Old Password',
                  labelStyle: TextStyle(fontSize: 16.sp),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOld ? Icons.visibility_off : Icons.visibility,
                      size: 24.sp,
                    ),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                ),
                style: TextStyle(fontSize: 16.sp),
                validator: AppValidator.validatePassword,
              ),
              SizedBox(height: 10.h),
              // New password
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(fontSize: 16.sp),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew ? Icons.visibility_off : Icons.visibility,
                      size: 24.sp,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                ),
                style: TextStyle(fontSize: 16.sp),
                validator: AppValidator.validatePassword,
              ),
              SizedBox(height: 10.h),
              // Confirm new password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(fontSize: 16.sp),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      size: 24.sp,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
                ),
                style: TextStyle(fontSize: 16.sp),
                validator: (value) => AppValidator.validateConfirmPassword(value, _newPasswordController.text),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(
            'Cancel',
            style: TextStyle(fontSize: 16.sp),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
            minimumSize: Size(80.w, 36.h),
          ),
          child: Text(
            'Submit',
            style: TextStyle(fontSize: 16.sp),
          ),
        ),
      ],
    );
  }
}