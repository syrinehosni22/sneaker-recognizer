import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- Add this

class GoogleSearchApi {
  final String apiKey = dotenv.env['GOOGLE_API_KEY']!;
  final String searchEngineId = dotenv.env['SEARCH_ENGINE_ID']!;

  Future<List<String>> searchLinks(String query) async {
    final url = Uri.parse(
      "https://www.googleapis.com/customsearch/v1?q=$query&key=$apiKey&cx=$searchEngineId",
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    final links = <String>[];
    if (data["items"] != null) {
      for (var item in data["items"]) {
        links.add(item["link"]);
      }
    }
    return links;
  }
}
