import 'dart:convert';
import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/utils/app_constant.dart';
import 'package:http/http.dart' as http;

abstract interface class AuthDataSource {
  Future<UserModel> login(String email, String password);
  Future<bool> register(String username, String email, String password);
  Future<String> forgotPassword(String email);
  Future<String> resetPassword(String token, String newPassword);
  Future<void> logout(String refreshToken);
}


class AuthRemoteDataSource implements AuthDataSource {

  final String baseUrl = AppConstant.baseUrl;

  AuthRemoteDataSource();


  @override
  Future<UserModel> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      print("Error: $e ");
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<bool> register(String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        print("Registered successful in data");
        return true;
      } else {
        print("Register failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }


  @override
  Future<String> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/user/forgot-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print(data);
        return data['message'] ?? 'Email sent';
      } else {
        throw Exception(data['message'] ?? 'Forgot password failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<String> resetPassword(String token, String newPassword) async {
    final url = Uri.parse('$baseUrl/user/reset-password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'newPassword': newPassword
        }),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['message'] ?? 'Password reset';
      } else {
        throw Exception(data['message'] ?? 'Reset password failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      final url = Uri.parse('$baseUrl/auth/logout');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        print('${body['message']}');
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error : $e');
    }
  }

}