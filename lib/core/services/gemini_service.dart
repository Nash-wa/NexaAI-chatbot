import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final Dio dio = Dio();

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
      print("Gemini API Error: $e");
      if (e is DioException) {
        print("DioError response: ${e.response?.data}");
        return "Error: ${e.message}\nResponse: ${e.response?.data}";
      }
      return "Error fetching AI response: $e";
    }
  }
}
