import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnvironment/teacher/create_subject_page.dart';
import 'package:learnvironment/services/auth_service.dart';
import 'package:learnvironment/services/data_service.dart';
import 'package:learnvironment/data/subject_data.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}
class MockDataService extends Mock implements DataService {}

void main() {
  late MockAuthService mockAuthService;
  late MockDataService mockDataService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockDataService = MockDataService();
  });

  Future<void> pumpCreateSubjectPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: mockAuthService),
          Provider<DataService>.value(value: mockDataService),
        ],
        child: const MaterialApp(
          home: CreateSubjectPage(),
        ),
      ),
    );
  }

  group('CreateSubjectPage Tests', () {
    testWidgets('renders correctly', (tester) async {
      await pumpCreateSubjectPage(tester);

      expect(find.text('Create Subject'), findsOneWidget);
      expect(find.text('Subject Name'), findsOneWidget);
      expect(find.text('Logo URL'), findsOneWidget);
      expect(find.text('Create Subject'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty', (tester) async {
      await pumpCreateSubjectPage(tester);

      await tester.tap(find.text('Create Subject'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a subject name'), findsOneWidget);
    });

    testWidgets('calls _createSubject successfully', (tester) async {
      when(mockAuthService.getUid()).thenAnswer((_) async => 'mockUserId');
      when(mockDataService.addSubject(subject: anyNamed('subject') as SubjectData))
          .thenAnswer((_) async => {});

      await pumpCreateSubjectPage(tester);

      // Enter valid data
      await tester.enterText(find.byType(TextFormField).at(0), 'Math');
      await tester.enterText(find.byType(TextFormField).at(1), 'https://example.com/image.png');

      await tester.tap(find.text('Create Subject'));
      await tester.pump(); // start async work
      await tester.pump(const Duration(seconds: 1)); // finish async work

      verify(mockDataService.addSubject(subject: anyNamed('subject') as SubjectData)).called(1);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('fallbacks to placeholder if image is invalid', (tester) async {
      when(mockAuthService.getUid()).thenAnswer((_) async => 'mockUserId');
      when(mockDataService.addSubject(subject: anyNamed('subject') as SubjectData))
          .thenAnswer((_) async => {});

      await pumpCreateSubjectPage(tester);

      // Enter invalid logo URL (simulate invalid image)
      await tester.enterText(find.byType(TextFormField).at(0), 'History');
      await tester.enterText(find.byType(TextFormField).at(1), 'invalid-url');

      await tester.tap(find.text('Create Subject'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final captured = verify(mockDataService.addSubject(subject: captureAnyNamed('subject') as SubjectData))
          .captured
          .first as SubjectData;

      expect(captured.subjectLogo, 'assets/placeholder.png');
    });

    testWidgets('shows error snackbar on failure', (tester) async {
      when(mockAuthService.getUid()).thenAnswer((_) async => 'mockUserId');
      when(mockDataService.addSubject(subject: anyNamed('subject') as SubjectData))
          .thenThrow(Exception('Failed to add subject'));

      await pumpCreateSubjectPage(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'Biology');
      await tester.enterText(find.byType(TextFormField).at(1), 'https://example.com/logo.png');

      await tester.tap(find.text('Create Subject'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('Failed to create subject'), findsOneWidget);
    });
  });
}