import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme.dart';

class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final IconData icon;
  final double? iconSize; // thêm dòng này
  final String? Function(String?)? validator;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.hint,
    this.isPassword = false,
    required this.icon,
    this.iconSize,  // thêm tham số
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Colors.grey,
          size: iconSize ?? 24.w, // dùng iconSize nếu có, hoặc mặc định 24.w
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: DefaultColors.sentMessageInput,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h), // responsive padding
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.r),  // responsive border radius
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}