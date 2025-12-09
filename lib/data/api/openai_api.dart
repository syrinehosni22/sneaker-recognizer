import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OpenAIApi {
  final String apiKey = dotenv.env['OPENAI_API_KEY']!;

  Future<String> recognizeSneaker(File imageFile) async {
    String base64Image = base64Encode(await imageFile.readAsBytes());

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/responses"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4.1-mini",
        "input": [
          {
            "role": "user",
            "content": [
              {
                "type": "input_image",
                "image_url": "data:image/png;base64,$base64Image"
              },
              {
                "type": "text",
                "text": "Identify the sneaker in this image and return only the brand and model."
              }
            ]
          }
        ]
      }),
    );

    final data = jsonDecode(response.body);
    return data["output_text"] ?? "Unknown sneaker";
  }
}
