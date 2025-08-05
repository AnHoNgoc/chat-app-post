import 'dart:io';

import 'package:chat_app/features/user/data/models/user_detail_model.dart';
import 'package:dio/dio.dart';
import '../../../../core/dio_client.dart';
import '../../../../utils/app_constant.dart';

class UserRemoteDataSource {

  final String baseUrl = AppConstant.baseUrl;

  UserRemoteDataSource();

  Future<UserDetailModel> fetchUser() async {
    String url = "$baseUrl/user";

    final dio = await DioClient.getDio();

    try {
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        return UserDetailModel.fromJson(json);
      } else {
        throw Exception("Failed to fetch user");
      }
    } catch (e) {
      print("fetchUser error: $e");
      rethrow;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    String url = "$baseUrl/user/change-password";
    final dio = await DioClient.getDio();

    try {
      final response = await dio.patch(
        url,
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200) {
        print("Changed password successfully");
        return true;
      } else {
        print("Changed password failed: ${response.data}");
        return false;
      }
    } catch (e) {
      print("changePassword error: $e");
      return false;
    }
  }

  Future<bool> updateUser(String username, String profileImage) async {
    String url = "$baseUrl/user/update-profile";
    final dio = await DioClient.getDio();

    try {
      final response = await dio.put(
        url,
        data: {
          'username': username,
          'profile_image': profileImage,
        },
      );

      if (response.statusCode == 200) {
        print("Updated user successfully");
        return true;
      } else {
        print("Update user failed: ${response.data}");
        return false;
      }
    } catch (e) {
      print("updateUser error: $e");
      return false;
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    String url = "$baseUrl/user/upload-profile-image";
    final dio = await DioClient.getDio();

    try {
      final formData = FormData.fromMap({
        'profile_image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await dio.post(
        url,
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['url']; // or response.data['data']['url'] if nested
      } else {
        throw Exception('Upload failed: ${response.data}');
      }
    } catch (e) {
      print('Upload error: $e');
      rethrow;
    }
  }
}
