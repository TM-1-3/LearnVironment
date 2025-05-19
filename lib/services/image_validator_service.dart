import 'package:http/http.dart' as http;

class ImageValidatorService {
  final http.Client _httpClient;

  ImageValidatorService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Validates whether the given URL points to a valid image (jpeg/png/gif/webp).
  Future<bool> validateImage(String imageUrl) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0',
        },
      );

      print('Status code: ${response.statusCode}');
      print('Content-Type: ${response.headers['content-type']}');

      if (response.statusCode != 200) return false;

      final contentType = response.headers['content-type'];
      if (contentType != null && contentType.startsWith('image/')) {
        return true;
      }
    } catch (e) {
      print('Request failed: $e');
    }

    return false;
  }
}
