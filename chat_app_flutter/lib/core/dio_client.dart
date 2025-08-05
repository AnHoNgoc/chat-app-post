import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/app_constant.dart';

class DioClient {
  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static Dio? _dio;

  static Future<Dio> getDio() async {
    if (_dio != null) return _dio!;

    _dio = Dio(BaseOptions(
      baseUrl: AppConstant.baseUrl,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final responseData = error.response?.data;
        final refreshToken = await _secureStorage.read(key: 'refreshToken');

        final isTokenExpired = responseData is Map<String, dynamic> &&
            responseData['message'] == "Token has expired";

        if (error.response?.statusCode == 401 && isTokenExpired) {
          try {
            final newToken = await _refreshAccessToken(refreshToken);

            if (newToken != null) {
              await _secureStorage.write(key: 'accessToken', value: newToken);

              print("Access token refreshed successfully.");

              final dio = await getDio(); // dùng lại Dio đúng cách
              final requestOptions = error.requestOptions;
              requestOptions.headers['Authorization'] = 'Bearer $newToken';

              final clonedResponse = await dio.fetch(requestOptions);
              return handler.resolve(clonedResponse);
            } else {
              await _secureStorage.deleteAll();
              return handler.reject(error);
            }
          } catch (e) {
            print('Error during token refresh: $e');
            return handler.reject(error);
          }
        }
        return handler.reject(error);
      },
    ));

    return _dio!;
  }

  static Future<String?> _refreshAccessToken(String? refreshToken) async {
    if (refreshToken == null) return null;

    try {
      final refreshDio = Dio(BaseOptions(
        baseUrl: AppConstant.baseUrl,
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 5),
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await refreshDio.post('/auth/refresh-token', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        return data['data']['accessToken'];
      }
      print('Refresh token failed with response: ${response.data}');
    } catch (e) {
      print('Error refreshing token: $e');
    }
    return null;
  }
}