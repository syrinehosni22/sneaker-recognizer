import 'dart:convert';
import 'package:http/http.dart' as http;

class SerpApiMapsService {
  static const String apiKey =
      "2d6de271f95ac3c27b09f880ece86971373c69253ec6ccbc3301de1cd0451109";

  static Future<Map<String, dynamic>?> fetchShop(
    String shopName,
    double lat,
    double lng,
  ) async {
    final response = await http.get(
      Uri.parse(
        "https://serpapi.com/search.json?engine=google_maps&q=${Uri.encodeComponent(shopName)}&ll=@$lat,$lng,14z&api_key=$apiKey",
      ),
    );

    if (response.statusCode != 200) return null;

    final results = jsonDecode(response.body)['local_results'] ?? [];
    return results.isNotEmpty ? results.first : null;
  }
}
