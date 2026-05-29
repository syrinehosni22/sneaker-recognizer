import 'dart:convert';
import 'package:http/http.dart' as http;

/// ================================
/// SMART PRODUCT SEARCH SERVICE
/// TOP 10 BEST MATCHES (NOT STRICT)
/// ================================
class ProductSearchService {
  static const String _apiKey =
      "2d6de271f95ac3c27b09f880ece86971373c69253ec6ccbc3301de1cd0451109";

  /// ================================
  /// MAIN SEARCH METHOD
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

      final data = jsonDecode(response.body);
      final List results = data["shopping_results"] ?? [];

      /// ================================
      /// SCORE ALL RESULTS (SMART RANKING)
      /// ================================
      final scored = results.map((item) {
        final title = (item["title"] ?? "").toString();

        final score = _calculateRelevanceScore(title, query);

        return {"item": item, "score": score};
      }).toList();

      /// ================================
      /// SORT BY BEST MATCH
      /// ================================
      scored.sort((a, b) => b["score"].compareTo(a["score"]));

      /// ================================
      /// TAKE TOP 10 ONLY
      /// ================================
      final top10 = scored.take(10);

      return top10.map<Map<String, dynamic>>((entry) {
        final item = entry["item"];

        return {
          "title": item["title"] ?? "",
          "price": _extractPrice(item["price"]),
          "shop": item["source"] ?? "",
          "link": item["link"] ?? "",
          "thumbnail": item["thumbnail"] ?? "",
          "image_url": item["serpapi_thumbnail"] ?? "",
          "score": entry["score"], // optional debug
        };
      }).toList();
    } catch (e) {
      throw Exception("Product search error: $e");
    }
  }

  /// ================================
  /// SMART RELEVANCE SCORING
  /// ================================
  static int _calculateRelevanceScore(String title, String query) {
    final normTitle = _normalize(title);
    final normQuery = _normalize(query);

    int score = 0;

    final queryWords = _splitWords(normQuery);
    final titleWords = _splitWords(normTitle);

    /// 1. strong boost if full query appears
    if (normTitle.contains(normQuery)) {
      score += 100;
    }

    /// 2. word overlap scoring (IMPORTANT)
    for (final word in queryWords) {
      if (titleWords.contains(word)) {
        score += 25;
      }
    }

    /// 3. brand-first boost (first word match)
    if (queryWords.isNotEmpty &&
        titleWords.isNotEmpty &&
        queryWords.first == titleWords.first) {
      score += 20;
    }

    /// 4. penalty for unrelated long titles
    if (titleWords.length > queryWords.length + 5) {
      score -= 10;
    }

    return score;
  }

  /// ================================
  /// SPLIT WORDS
  /// ================================
  static List<String> _splitWords(String input) {
    return input
        .split(RegExp(r'[^a-z0-9]+'))
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// ================================
  /// NORMALIZATION
  /// ================================
  static String _normalize(String input) {
    return input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
  }

  /// ================================
  /// PRICE CLEANER
  /// ================================
  static String _extractPrice(dynamic price) {
    if (price == null) return "0";

    return price.toString().replaceAll(RegExp(r'[^0-9.,]'), '');
  }
}
