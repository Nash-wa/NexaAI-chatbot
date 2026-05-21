import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class GeminiService {
  final Dio dio = Dio();
  static final Logger _logger = Logger('GeminiService');

  Future<String> sendMessage(String message) async {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];

      final response = await dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
        data: {
          "contents": [
            {
              "parts": [
                {"text": message}
              ]
            }
          ]
        },
      );

      final text = response
          .data['candidates'][0]['content']['parts'][0]['text'];

      return text;
    } catch (e) {
      _logger.severe('Gemini API Error: $e');
      if (e is DioException) {
        _logger.severe('DioError response: ${e.response?.data}');
        return "Error: ${e.message}\nResponse: ${e.response?.data}";
      }
      return "Error fetching AI response: $e";
    }
  }
}
