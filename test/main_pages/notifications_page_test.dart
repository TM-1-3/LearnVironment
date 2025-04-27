import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:learnvironment/student/student_home.dart';
import 'package:learnvironment/main_pages/notifications_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Mock class for FirebaseMessagingService
@override
class MockFirebaseMessagingService extends Mock implements FirebaseMessaging {
  // Mock the getter for notificationMessages
  List<RemoteMessage> get notificationMessages => super.noSuchMethod(
      Invocation.getter(#notificationMessages),
      returnValue: <RemoteMessage>[],
  ) as List<RemoteMessage>;
}

void main() {
  // Create a mock instance of FirebaseMessagingService
  late MockFirebaseMessagingService mockFirebaseMessagingService;

  setUp(() {
    mockFirebaseMessagingService = MockFirebaseMessagingService();
  });

  group('NotificationsPage Tests', () {
    testWidgets('displays the correct text when no notifications are available', (WidgetTester tester) async {
      // Prepare the mock service with no notifications
      when(mockFirebaseMessagingService.notificationMessages).thenReturn([]);

      // Build the widget tree
      await tester.pumpWidget(MaterialApp(
        home: NotificationsPage(),
      ));

      // Verify the text is displayed
      expect(find.text('No notifications yet!'), findsOneWidget);
    });

    testWidgets('displays notifications when available', (WidgetTester tester) async {
      // Prepare a mock notification message
      final mockNotification = RemoteMessage(
        notification: RemoteNotification(title: 'Test Title', body: 'Test Body'),
        sentTime: DateTime.now(),
      );

      // Mock the service to return a notification list
      when(mockFirebaseMessagingService.notificationMessages).thenReturn([mockNotification]);
      mockFirebaseMessagingService.notificationMessages.add(mockNotification);
      // Build the widget tree
      await tester.pumpWidget(MaterialApp(
        home: NotificationsPage(),
      ));
      await tester.pumpAndSettle();

      // Verify the notification is displayed
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Body'), findsOneWidget);
    });

    testWidgets('back button navigates to HomePage', (WidgetTester tester) async {
      // Build the widget tree
      await tester.pumpWidget(MaterialApp(
        home: NotificationsPage(),
        routes: {
          '/student_home': (context) => StudentHomePage(),
        },
      ));

      // Simulate pressing the back button
      await tester.tap(find.byIcon(Icons.arrow_back));

      // Wait for the navigation to complete
      await tester.pumpAndSettle();

      // Verify that we navigated back to StudentHomePage
      expect(find.byType(StudentHomePage), findsOneWidget);
    });

    testWidgets('displays notification sent time', (WidgetTester tester) async {
      final mockNotification = RemoteMessage(
        notification: RemoteNotification(title: 'Test Title', body: 'Test Body'),
        sentTime: DateTime(2025, 04, 26, 15, 30),
      );

      // Mock the service to return the notification
      when(mockFirebaseMessagingService.notificationMessages).thenReturn([mockNotification]);

      // Build the widget tree
      await tester.pumpWidget(MaterialApp(
        home: NotificationsPage(),
      ));

      // Verify that the sent time is displayed
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

      // Mock the service to return two notifications
      when(mockFirebaseMessagingService.notificationMessages).thenReturn([notification1, notification2]);

      // Build the widget tree
      await tester.pumpWidget(MaterialApp(
        home: NotificationsPage(),
      ));

      // Verify that both notifications are displayed
      expect(find.text('Title 1'), findsOneWidget);
      expect(find.text('Body 1'), findsOneWidget);
      expect(find.text('Title 2'), findsOneWidget);
      expect(find.text('Body 2'), findsOneWidget);
    });
  });
}
