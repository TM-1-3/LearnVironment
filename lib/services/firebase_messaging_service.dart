import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:learnvironment/data/notification_storage.dart';

class FirebaseMessagingService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  FirebaseMessagingService({
    FlutterLocalNotificationsPlugin? localNotificationsPlugin,
  })  : flutterLocalNotificationsPlugin = localNotificationsPlugin ?? FlutterLocalNotificationsPlugin();

  Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message, {bool flag = false}) async {
    if (!flag) {
      await Firebase.initializeApp();
    }
    showNotification(message);
  }

  Future<void> initNotifications({InitializationSettings? initializationSettings, AndroidNotificationChannel? channel}) async {
    initializationSettings ??= const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    channel ??= const AndroidNotificationChannel(
      'default_channel',
      'Default Notifications',
      description: 'This channel is used for FCM notifications.',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void showNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      final androidDetails = AndroidNotificationDetails(
        'default_channel',
        'Default Notifications',
        channelDescription: 'This channel is used for FCM notifications.',
        importance: Importance.high,
        priority: Priority.high,
      );

      final platformDetails = NotificationDetails(android: androidDetails);

      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
      );
    }
  }

  void setupFCMListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('FCM message received in foreground');
      showNotification(message);
      NotificationStorage.notificationMessages.add(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification: ${message.data}');
      // Navigate to a specific screen if needed
    });
  }
}
