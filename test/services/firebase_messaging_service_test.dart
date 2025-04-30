import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:learnvironment/services/firebase_messaging_service.dart';
import 'package:learnvironment/data/notification_storage.dart';

@GenerateNiceMocks([
  MockSpec<FlutterLocalNotificationsPlugin>(),
  MockSpec<FirebaseMessaging>()
])

import 'firebase_messaging_service_test.mocks.dart';

void main() {
  late MockFlutterLocalNotificationsPlugin mockFlutterLocalNotificationsPlugin;
  late FirebaseMessagingService firebaseMessagingService;

  setUp(() {
    mockFlutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    firebaseMessagingService = FirebaseMessagingService(localNotificationsPlugin: mockFlutterLocalNotificationsPlugin);
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

      firebaseMessagingService.showNotification(message);

      verify(mockFlutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        message.notification!.title,
        message.notification!.body,
        any,
      )).called(1);
    });

    test('should not crash when notification or android details are missing', () async {
      final RemoteMessage message = RemoteMessage(data: {});

      firebaseMessagingService.showNotification(message);

      verifyNever(mockFlutterLocalNotificationsPlugin.show(any, any, any, any));
    });

    test('should update NotificationStorage when receiving foreground message', () async {
      // Arrange: Create a fake message
      final RemoteMessage fakeMessage = RemoteMessage(
        notification: RemoteNotification(title: 'Fake Title', body: 'Fake Body'),
        data: {},
      );


      firebaseMessagingService.setupFCMListeners();

      expect(NotificationStorage.notificationMessages.contains(fakeMessage), isTrue);
    });

    test('should execute onMessageOpenedApp listener correctly', () async {
      final RemoteMessage message = RemoteMessage(
        notification: RemoteNotification(title: 'Opened Title', body: 'Opened Body'),
        data: {"key": "value"},
      );

      firebaseMessagingService.setupFCMListeners();

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        expect(message.data['key'], equals("value"));
      });
    });
  });
}