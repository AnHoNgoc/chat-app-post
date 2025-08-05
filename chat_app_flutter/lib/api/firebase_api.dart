import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final notificationService = NotificationService();

    final fcmToken = await _firebaseMessaging.getToken();
    print('🔑 FCM Token: $fcmToken');

    if (fcmToken != null) {
      try {
        await notificationService.sendFcmToken(fcmToken);
      } catch (e) {
        print('❗ Failed to send FCM token: $e');
      }
    }

    // App đang foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📥 Notification in foreground: ${message.notification?.title}');
      NotificationService.showNotification(message);
    });

    // App background, user click notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 onMessageOpenedApp triggered');
      NotificationService.handleNotificationClick(message.data);
    });

    // // App vừa mở lên từ trạng thái tắt hoàn toàn (terminated)
    // RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    // if (initialMessage != null && initialMessage.data.isNotEmpty) {
    //   print('📲 App opened via notification from terminated state');
    //   NotificationService.handleNotificationClick(initialMessage.data);
    // }
  }

}