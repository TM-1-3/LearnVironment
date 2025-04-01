import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/authentication/auth_service.dart';
import 'package:learnvironment/home_page.dart'; // Import HomePage widget
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Create a mock AuthService class
class MockAuthService extends Mock implements AuthService {}

void main() {
  testWidgets('Show Message and Logout Button work correctly', (WidgetTester tester) async {
    // Create a mock AuthService instance
    final mockAuthService = MockAuthService();

    // Build the widget tree with a Provider for AuthService
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AuthService>(
          create: (_) => mockAuthService,
          child: const HomePage(),
        ),
      ),
    );

    // Initial state should have no message
    expect(find.text('Button Pressed!'), findsNothing);
    expect(find.text('Logged Out'), findsNothing);

    // Test the Show Message Button
    await tester.tap(find.text('Show Message'));
    await tester.pump(); // Rebuild the widget tree

    // After tapping the "Show Message" button, the message should appear
    expect(find.text('Button Pressed!'), findsOneWidget);

    // Test the Logout Button
    await tester.tap(find.text('Logout'));
    await tester.pump(); // Rebuild the widget tree

    // After tapping the "Logout" button, the message should update to "Logged Out"
    expect(find.text('Logged Out'), findsOneWidget);
  });
}
