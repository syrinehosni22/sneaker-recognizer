import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> googleSearchProducts(String query) async {
  const apiKey = "YOUR_GOOGLE_API_KEY";
  const cx = "YOUR_SEARCH_ENGINE_ID";

  final url = Uri.parse(
    "https://www.googleapis.com/customsearch/v1"
    "?key=$apiKey"
    "&cx=$cx"
    "&q=${Uri.encodeComponent(query + " price buy shop")}",
  );

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception("Google Search error: ${response.body}");
  }

  final json = jsonDecode(response.body);
  final List items = json['items'] ?? [];

  return items.map<Map<String, dynamic>>((item) {
    final snippet = item['snippet'] ?? "";
    final title = item['title'] ?? "";

    // Tentative d'extraction du prix
    final priceMatch = RegExp(r'(\$|€|£)?\s?\d+[.,]?\d*').firstMatch(snippet);

    return {
      "title": title,
      "snippet": snippet,
      "link": item['link'],
      "shop": item['displayLink'],
      "price": priceMatch?.group(0),
    };
  }).toList();
}
