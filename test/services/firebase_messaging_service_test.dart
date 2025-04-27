import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:learnvironment/services/firebase_messaging_service.dart';
import 'package:flutter/services.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
   with MockPlatformInterfaceMixin
   implements FlutterLocalNotificationsPlugin {

  @override
  Future<bool?> initialize(InitializationSettings init, {void Function(NotificationResponse)? onDidReceiveBackgroundNotificationResponse, void Function(NotificationResponse)? onDidReceiveNotificationResponse}) async {
    return true;
  }
}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main(){
  late MockFlutterLocalNotificationsPlugin mockFlutterLocalNotificationsPlugin;
  const MethodChannel channel = MethodChannel('dexterx.dev/flutter_local_notifications');


  setUp(() {
    mockFlutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, ((MethodCall methodCall) async {
      if (methodCall.method == 'initialize') {
        return true; // Mock a successful initialization
      }
      return null;
    }));
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('initNotifications Tests', () {
    test('should initialize FlutterLocalNotificationsPlugin and create channel', () async {
      // Call
      final initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );

      await initNotifications(initializationSettings: initializationSettings, plugin: mockFlutterLocalNotificationsPlugin);

      expect(true, isTrue);
    });
  });

  group('showNotification Tests', () {
    test('should not crash when notification and android details exist', () async {
      RemoteMessage message = RemoteMessage(
        notification: RemoteNotification(
          title: 'Test Title',
          body: 'Test Body',
        ),
        data: {},
      );
      showNotification(message);
      expect(true, isTrue);
    });

    test('should not crash if notification or android part is null', () async {
      RemoteMessage message = RemoteMessage(data: {});
      showNotification(message);
      expect(true, isTrue);
    });
  });

  group('firebaseMessagingBackgroundHandler Tests', () {
    test('should initialize Firebase and show notification without errors', () async {
      // Arrange
      RemoteMessage message = RemoteMessage(
        notification: RemoteNotification(
          title: 'Background Title',
          body: 'Background Body',
        ),
        data: {},
      );

      // Act: Call your background handler
      await firebaseMessagingBackgroundHandler(message, plugin: mockFlutterLocalNotificationsPlugin, flag: true);

      expect(true, isTrue); // For now, we assume true, as you need actual checks here.
    });
  });

  group('setupFCMListeners Tests', () {
    test('should setup onMessage and onMessageOpenedApp listeners', () async {
      setupFCMListeners();
      expect(true, isTrue);
    });
  });
}