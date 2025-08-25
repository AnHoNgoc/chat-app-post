import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/dio_client.dart';
import '../features/auth/presentation/screens/login_page.dart';
import '../features/chat/presentation/screens/chat_page.dart';
import '../main.dart';
import '../utils/app_constant.dart';

class NotificationService {

  Future<void> sendFcmToken(String fcmToken) async {
    final String baseUrl = AppConstant.baseUrl;

    try {
      final dio = await DioClient.getDio();
      final url = "$baseUrl/fcm/save-token";

      final response = await dio.post(
        url,
        data: {
          "fcmToken": fcmToken,
        },
      );

      if (response.statusCode == 200) {
        print('✅ FCM token successfully sent to the server.');
      } else {
        print('❌ Failed to send token. Status: ${response.statusCode}, Message: ${response.statusMessage}');
      }
    } catch (e) {
      print('❌ Exception while sending FCM token: $e');
    }
  }

  static final  _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null) {
          try {
            final data = jsonDecode(payload);
            handleNotificationClick(data);
          } catch (e) {
            print('❌ Failed to parse notification payload: $e');
          }
        }
      },
    );
  }

  static Future<void> showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.notification.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  static final _storage = FlutterSecureStorage();

  static Future<bool> _isUserLoggedIn() async {
    final token = await _storage.read(key: "accessToken");
    return token != null && token.isNotEmpty;
  }

  static Map<String, dynamic>? _pendingData;

  static Future<void> handleNotificationClick(Map<String, dynamic> data) async {
    final loggedIn = await _isUserLoggedIn();
    if (loggedIn) {
      _navigateToChat(data);
    } else {
      print('⚠️ User chưa đăng nhập, lưu notification lại');
      _pendingData = data;

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
      );
    }
  }

  static Future<void> processPendingNotificationIfNeeded() async {
    final loggedIn = await _isUserLoggedIn();
    if (_pendingData != null && loggedIn) {
      _navigateToChat(_pendingData!);
      _pendingData = null;
    }
  }

  static void _navigateToChat(Map<String, dynamic> data) {
    final conversationId = data['conversationId'];
    final mate = data['mate'] ?? 'Stranger';
    final profileImage = data['profileImage'] ?? '';

    if (conversationId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => ChatPage(
            conversationId: conversationId,
            mate: mate,
            profileImage: profileImage,
          ),
        ),
      );
    } else {
      print('❗ No conversationId in notification data.');
    }
  }
}