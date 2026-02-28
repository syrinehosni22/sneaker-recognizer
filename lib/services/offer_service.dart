import 'dart:convert';
import 'package:flutter/foundation.dart'; // ✅ Added this for debugPrint
import 'package:http/http.dart' as http;
import '../domain/models/Offer.dart';

class OfferService {
  static const String _baseUrl = 'http://localhost:5000/api/offers';

  static String? _internalToken;

  static void setToken(String token) {
    _internalToken = token;
    debugPrint("OfferService: Token updated.");
    print(_internalToken);
  }

  static Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Authorization": "Bearer $_internalToken",
  };

  static Future<List<Offer>> fetchOffers() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl), headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = json.decode(response.body);

        // 1. Look for the list inside the 'data' key (or whatever your backend uses)
        // If your backend returns the list directly, use: decodedData as List<dynamic>
        final List<dynamic> body = decodedData['data'] ?? [];

        return body.map((item) => Offer.fromJson(item)).toList();
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("FetchOffers Error: $e");
      // This helps you see what exactly the server sent back
      throw Exception("Data format error. Check console for details.");
    }
  }

  static Future<bool> addOffer(Map<String, dynamic> offerData) async {
    try {
      print('_headers');
      print(_headers);
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _headers,
        body: json.encode(offerData),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint("AddOffer Error: $e");
      return false;
    }
  }
}
