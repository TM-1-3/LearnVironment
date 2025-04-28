import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/main_pages/notifications_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:learnvironment/authentication/auth_gate.dart';

class MockAuthGate extends AuthGate {
  MockAuthGate({key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Mock AuthGate Screen'),
      ),
    );
  }
}

void main() {

  group('NotificationsPage Tests', () {
    testWidgets('displays the correct text when no notifications are available', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: NotificationsPage(notifications: []),));

      expect(find.text('No notifications yet!'), findsOneWidget);
    });

    testWidgets('displays notifications when available', (WidgetTester tester) async {
      final mockNotification = RemoteMessage(
        notification: RemoteNotification(title: 'Test Title', body: 'Test Body'),
        sentTime: DateTime.now(),
      );

      List<RemoteMessage> notifications = [];
      notifications.add(mockNotification);

      await tester.pumpWidget(MaterialApp(
        home: NotificationsPage(notifications: notifications),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Body'), findsOneWidget);
    });

    testWidgets('back button navigates to HomePage', (WidgetTester tester) async {
      // Build the widget tree
      await tester.pumpWidget(MaterialApp(
        home: NotificationsPage(),
        routes: {
          '/auth_gate': (context) => MockAuthGate(),
        },
      ));
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(MockAuthGate), findsOneWidget);
    });

    testWidgets('displays notification sent time', (WidgetTester tester) async {
      final mockNotification = RemoteMessage(
        notification: RemoteNotification(title: 'Test Title', body: 'Test Body'),
        sentTime: DateTime(2025, 04, 26, 15, 30),
      );

      List<RemoteMessage> notifications = [];
      notifications.add(mockNotification);

      await tester.pumpWidget(MaterialApp(
        home: NotificationsPage(notifications: notifications),
      ));

      expect(find.text('2025-04-26 15:30:00'), findsOneWidget);
    });

    testWidgets('displays multiple notifications correctly', (WidgetTester tester) async {
      final notification1 = RemoteMessage(
        notification: RemoteNotification(title: 'Title 1', body: 'Body 1'),
        sentTime: DateTime(2025, 04, 26, 15, 30),
      );
      final notification2 = RemoteMessage(
        notification: RemoteNotification(title: 'Title 2', body: 'Body 2'),
        sentTime: DateTime(2025, 04, 26, 16, 30),
      );

      List<RemoteMessage> notifications = [];
      notifications.add(notification1);
      notifications.add(notification2);

      await tester.pumpWidget(MaterialApp(
        home: NotificationsPage(notifications: notifications),
      ));

      // Verify that both notifications are displayed
      expect(find.text('Title 1'), findsOneWidget);
      expect(find.text('Body 1'), findsOneWidget);
      expect(find.text('Title 2'), findsOneWidget);
      expect(find.text('Body 2'), findsOneWidget);
    });
  });
}
