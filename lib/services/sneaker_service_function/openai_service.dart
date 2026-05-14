import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  static Future<String> identifySneaker(String imageUrl) async {
    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/responses"),
      headers: {
        "Authorization": "Bearer ${String.fromEnvironment('OPENAI_API_KEY')}",
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
