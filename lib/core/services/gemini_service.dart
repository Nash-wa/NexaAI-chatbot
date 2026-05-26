import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class GeminiService {
  GeminiService([Dio? dio]) : _dio = dio ?? Dio(_defaultOptions);

  static final Logger _logger = Logger('GeminiService');

  final Dio _dio;

  static BaseOptions get _defaultOptions => BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {
          'Content-Type': 'application/json',
        },
      );

  Future<String> sendMessage(String message, {String? systemPrompt}) async {
    var apiKey = dotenv.env['GEMINI_API_KEY']?.trim();
    if (apiKey != null && apiKey.startsWith('"') && apiKey.endsWith('"')) {
      apiKey = apiKey.substring(1, apiKey.length - 1).trim();
    }

    if (apiKey == null || apiKey.isEmpty) {
      throw StateError(
        'GEMINI_API_KEY is not configured. Add your real key to .env without quotes and restart the app.',
      );
    }

    try {
      final requestData = <String, dynamic>{
        'contents': [
          {
            'parts': [
              {'text': message}
            ]
          }
        ],
      };

      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        requestData['systemInstruction'] = {
          'parts': [
            {'text': systemPrompt}
          ]
        };
      }

      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
        data: requestData,
      );

      _logger.info('Status Code: ${response.statusCode}');
      _logger.info('Response Data: ${response.data}');

      final candidate = response.data['candidates']?.first;
      final content = candidate?['content']?['parts']?.first?['text'];

      if (content is String && content.isNotEmpty) {
        return content.trim();
      }

      throw Exception('Gemini returned an empty response.');
    } on DioException catch (error, stackTrace) {
      _logger.severe('DioException Status: ${error.response?.statusCode}');
      _logger.severe('DioException Data: ${error.response?.data}');
      _logger.severe('DioException Message: ${error.message}');
      _logger.severe('Gemini API Error', error, stackTrace);
      final responseBody = error.response?.data;
      throw Exception(
          'Failed to fetch AI response. ${error.message} ${responseBody != null ? '\n$responseBody' : ''}');
    } catch (error, stackTrace) {
      _logger.severe('Gemini service failure', error, stackTrace);
      rethrow;
    }
  }
}
