import 'package:http/http.dart' as http;
import 'package:learnvironment/services/image_validator_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'image_validator_service_test.mocks.dart';


@GenerateMocks([http.Client])

void main() {
  late MockClient mockHttpClient;
  late ImageValidatorService imageValidatorService;

  setUp(() {
    mockHttpClient = MockClient();
    imageValidatorService = ImageValidatorService(httpClient: mockHttpClient);
  });

  test('should return true for valid image URL', () async {
    final imageUrl = 'https://example.com/image.png';

    // Mock a successful response with an image content type
    when(mockHttpClient.get(Uri.parse(imageUrl), headers: anyNamed('headers')))
        .thenAnswer(
          (_) async => http.Response(
        '',
        200,
        headers: {'content-type': 'image/png'},
      ),
    );

    final result = await imageValidatorService.validateImage(imageUrl);

    expect(result, true);
  });

  test('should return false for non-image content type', () async {
    final imageUrl = 'https://example.com/file.txt';

    // Mock a response with a non-image content type (text)
    when(mockHttpClient.get(Uri.parse(imageUrl), headers: anyNamed('headers')))
        .thenAnswer(
          (_) async => http.Response(
        '',
        200,
        headers: {'content-type': 'text/html'},
      ),
    );

    final result = await imageValidatorService.validateImage(imageUrl);

    expect(result, false);
  });

  test('should return false for 404 error', () async {
    final imageUrl = 'https://example.com/nonexistent_image.png';

    // Mock a 404 response
    when(mockHttpClient.get(Uri.parse(imageUrl), headers: anyNamed('headers')))
        .thenAnswer(
          (_) async => http.Response('Not Found', 404),
    );

    final result = await imageValidatorService.validateImage(imageUrl);

    expect(result, false);
  });

  test('should return false when there is an exception', () async {
    final imageUrl = 'https://example.com/image.png';

    // Simulate a network error
    when(mockHttpClient.get(Uri.parse(imageUrl), headers: anyNamed('headers')))
        .thenThrow(Exception('Network error'));

    final result = await imageValidatorService.validateImage(imageUrl);

    expect(result, false);
  });
}
