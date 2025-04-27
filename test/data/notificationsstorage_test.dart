import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:learnvironment/data/notification_storage.dart';

void main() {
  group('NotificationMessages Storage Tests', () {
    test('should add notification to notificationMessages when received', () {
      final initialLength = NotificationStorage.notificationMessages.length;

      RemoteMessage message = RemoteMessage(
        notification: RemoteNotification(
          title: 'Foreground Title',
          body: 'Foreground Body',
        ),
        data: {},
      );

      NotificationStorage.notificationMessages.add(message);

      expect(NotificationStorage.notificationMessages.length, initialLength + 1);
      expect(NotificationStorage.notificationMessages.last.notification?.title, 'Foreground Title');
    });
  });
}