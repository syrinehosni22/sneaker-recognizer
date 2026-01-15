import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String openAiKey =
      "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";

  static Future<String> identifySneaker(String imageUrl) async {
    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/responses"),
      headers: {
        "Authorization": "Bearer $openAiKey",
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
                    "Identify the exact product model (brand, model, colorway). Reply only with the model name.",
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
    return json['output'][0]['content'][0]['text'].trim();
  }
}
