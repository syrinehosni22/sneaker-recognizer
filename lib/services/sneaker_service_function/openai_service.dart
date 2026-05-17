import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static String get apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static Future<String> identifySneaker(String imageUrl) async {
    if (apiKey.isEmpty) {
      throw Exception("Missing OPENAI API KEY");
    }

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/responses"),
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4.1-mini",
        "input": [
          {
            "role": "user",
            "content": [
              {
                "type": "input_text",
                "text":
                    "Identify the exact sneaker model (brand, model, colorway). Return only the model name.",
              },
              {"type": "input_image", "image_url": imageUrl},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final json = jsonDecode(response.body);
    return json['output'][0]['content'][0]['text'].toString().trim();
  }
}
