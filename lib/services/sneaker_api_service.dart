import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class SneakerApiService {
  // ===============================
  // KEYS (⚠️ move to env later)
  static const String serpApiKey =
      "2d6de271f95ac3c27b09f880ece86971373c69253ec6ccbc3301de1cd0451109";

  static const String openAiKey =
      "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";

  static const String cloudName = "dji6iofcr";
  static const String uploadPreset = "flutter_mvp_upload";

  // ===============================
  // UPLOAD IMAGE TO CLOUDINARY
  static Future<String> uploadImage(XFile image) async {
    final bytes = await image.readAsBytes();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
    );

    request.fields['upload_preset'] = uploadPreset;
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: image.name),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception("Cloudinary upload failed: $body");
    }

    final data = jsonDecode(body);
    return data['secure_url'];
  }

  // ===============================
  // IDENTIFY SNEAKER MODEL WITH GPT
  static Future<String> getSneakerModel(XFile image) async {
    final imageUrl = await uploadImage(image);

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
                    "Identify the exact sneaker model (brand, model, colorway). Reply only with the model name.",
              },
              {"type": "input_image", "image_url": imageUrl},
            ],
          },
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("OpenAI failed: ${response.body}");
    }

    final json = jsonDecode(response.body);
    return json['output'][0]['content'][0]['text'].trim();
  }

  // ===============================
  // MAIN FUNCTION: GET SNEAKER DATA
  static Future<Map<String, dynamic>> getSneakerData(XFile image) async {
    try {
      // 1️⃣ Identify sneaker model
      final sneakerModel = await getSneakerModel(image);

      // 2️⃣ Check GPS
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final lat = position.latitude;
      final lng = position.longitude;

      // 3️⃣ Fetch prices from Google Shopping
      final pricesResponse = await http.get(
        Uri.parse(
          "https://serpapi.com/search.json?engine=google_shopping&q=${Uri.encodeComponent(sneakerModel)}&gl=fr&hl=en&api_key=$serpApiKey",
        ),
      );

      if (pricesResponse.statusCode != 200) {
        throw Exception(pricesResponse.body);
      }

      final pricesJson = jsonDecode(pricesResponse.body);
      final List<dynamic> pricesList = pricesJson['shopping_results'] ?? [];

      // 4️⃣ Map base results
      List<Map<String, dynamic>> results = [];
      for (final item in pricesList) {
        results.add({
          "price": item['price'],
          "currency": item['currency'],
          "thumbnail": item['thumbnail'],
          "productLink": item['product_link'],
          "shopName": item['source'],
          "shopWebsite": null,
          "shopAddress": null,
          "shopRating": null,
          "shopReviews": null,
          "shopPhone": null,
          "shopLocation": null,
          "googleMapsLink": null,
        });
      }

      // 5️⃣ Enrich results with both website and Google Maps
      await enrichResultsWithShopData(results, lat, lng);
      //6- sort results
      sortResults(results);
      return {"model": sneakerModel, "results": sortResults(results)};
    } catch (e) {
      print("getSneakerData error: $e");
      rethrow;
    }
  }

  // ===============================
  static Future<void> enrichResultsWithShopData(
    List<Map<String, dynamic>> results,
    double lat,
    double lng,
  ) async {
    await Future.wait(
      results.map((item) async {
        final shopName = item['shopName'];
        if (shopName == null || shopName.isEmpty) return;

        try {
          final response = await http.get(
            Uri.parse(
              "https://serpapi.com/search.json"
              "?engine=google_maps"
              "&q=${Uri.encodeComponent(shopName)}"
              "&ll=@$lat,$lng,14z"
              "&hl=en"
              "&api_key=$serpApiKey",
            ),
          );

          if (response.statusCode != 200) return;

          final json = jsonDecode(response.body);
          final List results = json['local_results'] ?? [];
          if (results.isEmpty) return;

          final shop = results.first;
          final gps = shop['gps_coordinates'];

          // 🔹 UPDATE ITEM IN PLACE
          item['shopWebsite'] = shop['website'];
          item['shopAddress'] = shop['address'];
          item['shopRating'] = shop['rating'];
          item['shopReviews'] = shop['reviews'];
          item['shopPhone'] = shop['phone'];

          if (gps != null) {
            item['shopLocation'] = {
              "lat": gps['latitude'],
              "lng": gps['longitude'],
            };

            item['googleMapsLink'] =
                "https://www.google.com/maps/search/?api=1&query=${gps['latitude']},${gps['longitude']}";
          }
        } catch (e) {
          print("enrichResultsWithShopData error: $e");
        }
      }),
    );
  }

  // ===============================
  // SORT RESULTS BY PRICE OR DISTANCE
  static List<Map<String, dynamic>> sortResults(
    List<Map<String, dynamic>> results, {
    String sortBy = "price",
    bool ascending = true,
  }) {
    List<Map<String, dynamic>> sortedResults = List.from(results);

    double parsePrice(String? value) {
      if (value == null || value.isEmpty) return double.infinity;

      // Nettoie la chaîne : retire € et tout caractère sauf chiffres et séparateur décimal
      final cleaned = value
          .replaceAll(RegExp(r'[^\d.,]'), '')
          .replaceAll(',', '.');

      // Convertit en double
      return double.tryParse(cleaned) ?? double.infinity;
    }

    sortedResults.sort((a, b) {
      final aValue = parsePrice(a[sortBy]?.toString());
      final bValue = parsePrice(b[sortBy]?.toString());
      return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });

    return sortedResults;
  }
}
