import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//Temporary notification storage
List<RemoteMessage> notificationMessages = [];

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message, {FlutterLocalNotificationsPlugin? plugin, bool? flag}) async {
  if (flag == true) {
    //nothing
  } else {
    await Firebase.initializeApp();
  }

  plugin ??= flutterLocalNotificationsPlugin;
  showNotification(message, plugin: plugin);
}

Future<void> initNotifications({
  InitializationSettings? initializationSettings,
  AndroidNotificationChannel? channel,
  FlutterLocalNotificationsPlugin? plugin
}) async {
  initializationSettings ??= const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );

  channel ??= const AndroidNotificationChannel(
    'default_channel',
    'Default Notifications',
    description: 'This channel is used for FCM notifications.',
    importance: Importance.high,
  );

  plugin ??= flutterLocalNotificationsPlugin;

  // Initialize notifications
  await plugin.initialize(initializationSettings);

  // Create the notification channel
  await plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
}

void showNotification(RemoteMessage message, {FlutterLocalNotificationsPlugin? plugin}) {
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

    plugin ??= flutterLocalNotificationsPlugin;

    plugin.show(
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
    notificationMessages.add(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('App opened from notification: ${message.data}');
    // Navigate to a specific screen if needed
  });
}