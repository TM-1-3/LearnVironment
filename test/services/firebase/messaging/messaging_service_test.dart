import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:learnvironment/services/firebase/messaging_service.dart';
import 'package:learnvironment/data/notification_storage.dart';

@GenerateNiceMocks([
  MockSpec<FlutterLocalNotificationsPlugin>(),
  MockSpec<FirebaseMessaging>()
])

import 'messaging_service_test.mocks.dart';

void main() {
  late MockFlutterLocalNotificationsPlugin mockFlutterLocalNotificationsPlugin;
  late MessagingService firebaseMessagingService;
  late MockFirebaseMessaging mockFirebaseMessaging;

  setUp(() {
    mockFirebaseMessaging = MockFirebaseMessaging();
    mockFlutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    firebaseMessagingService = MessagingService(localNotificationsPlugin: mockFlutterLocalNotificationsPlugin, firebaseMessaging: mockFirebaseMessaging);
  });

  group('FirebaseMessagingService Tests', () {
    test('should initialize FlutterLocalNotificationsPlugin and create channel', () async {
      final initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );

      await firebaseMessagingService.initNotifications(
        initializationSettings: initializationSettings);

      verify(mockFlutterLocalNotificationsPlugin.initialize(initializationSettings)).called(1);
    });

    test('should show notification when message contains valid notification data', () async {
      final RemoteMessage message = RemoteMessage(
        notification: RemoteNotification(
          title: 'Test Title',
          body: 'Test Body',
          android: AndroidNotification(),
        ),
        data: {},
      );

      MessagingService.showNotification(message: message, localNotificationsPlugin: mockFlutterLocalNotificationsPlugin);

      verify(mockFlutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        message.notification!.title,
        message.notification!.body,
        any,
      )).called(1);
    });

    test('should not crash when notification or android details are missing', () async {
      final RemoteMessage message = RemoteMessage(data: {});

      MessagingService.showNotification(message: message, localNotificationsPlugin: mockFlutterLocalNotificationsPlugin);

      verifyNever(mockFlutterLocalNotificationsPlugin.show(any, any, any, any));
    });

    test('should not update NotificationStorage if no message received', () async {
      firebaseMessagingService.setupFCMListeners();

      expect(NotificationStorage.notificationMessages.isEmpty, isTrue);
    });
  });
}