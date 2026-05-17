import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> googleSearchProducts(String query) async {
  const apiKey =
      "2d6de271f95ac3c27b09f880ece86971373c69253ec6ccbc3301de1cd0451109";
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

class SerpApiShoppingService {
  // 🔑 Put your real SerpAPI key here
  static const String _apiKey =
      "2d6de271f95ac3c27b09f880ece86971373c69253ec6ccbc3301de1cd0451109";

  /// ================================
  /// SEARCH PRODUCTS (GOOGLE SHOPPING)
  /// ================================
  static Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final uri = Uri.parse(
        "https://serpapi.com/search.json"
        "?engine=google_shopping"
        "&q=${Uri.encodeComponent(query)}"
        "&api_key=$_apiKey",
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception("SerpAPI request failed: ${response.statusCode}");
      }
      print("SerpApi");
      print(response.body);
      final data = jsonDecode(response.body);

      final List results = data["shopping_results"] ?? [];
      return results.map<Map<String, dynamic>>((item) {
        return {
          "title": item["title"] ?? "Unknown product",
          "price": _extractPrice(item["price"]),
          "shop": item["source"],
          "link": item["link"] ?? "",
          "thumbnail": item["thumbnail"] ?? "",
          "image_url": item["serpapi_thumbnail"],
        };
      }).toList();
    } catch (e) {
      throw Exception("SerpAPI error: $e");
    }
  }

  /// ================================
  /// PRICE CLEANER
  /// ================================
  static String _extractPrice(dynamic price) {
    if (price == null) return "0";

    // SerpAPI sometimes returns "120 €" or "$120"
    return price.toString().replaceAll(RegExp(r'[^0-9.,]'), '');
  }
}
