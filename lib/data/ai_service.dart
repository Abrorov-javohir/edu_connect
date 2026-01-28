import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static const String _apiKey = "AIzaSyBQIqVpLcafT45bg6iDed8CXJLpcDXD7Qo";

  final _model = GenerativeModel(
    model: 'gemini-2.5-flash', // Updated from 1.5
    apiKey: _apiKey,
    requestOptions: const RequestOptions(apiVersion: 'v1'),
  );
  Stream<String> getStreamingResponse(String prompt) async* {
    try {
      final content = [Content.text(prompt)];
      final response = _model.generateContentStream(content);

      String fullText = "";
      await for (final chunk in response) {
        if (chunk.text != null) {
          fullText += chunk.text!;
          yield fullText;
        }
      }
    } catch (e) {
      yield "Xatolik: $e";
    }
  }
}
