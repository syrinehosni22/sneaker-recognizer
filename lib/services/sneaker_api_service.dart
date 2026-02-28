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
                    "Identify the exact product model (brand, model, colorway). Reply  with the exact model name brand colorway.",
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
  // ===============================
  // MAIN FUNCTION: GET PRODUCT DATA
  static Future<Map<String, dynamic>> getProductData(XFile image) async {
    try {
      // 1️⃣ Identify sneaker model
      final sneakerModel = await getSneakerModel(image);

      // 2️⃣ Check GPS
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

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

      // 3️⃣ Get prices from SerpAPI
      final pricesResponse = await http.get(
        Uri.parse(
          "https://serpapi.com/search.json"
          "?engine=google_shopping"
          "&q=${Uri.encodeComponent(sneakerModel)}"
          "&gl=fr&hl=en"
          "&api_key=$serpApiKey",
        ),
      );

      if (pricesResponse.statusCode != 200) {
        throw Exception(pricesResponse.body);
      }

      final pricesJson = jsonDecode(pricesResponse.body);
      final List pricesList = pricesJson['shopping_results'] ?? [];

      // 4️⃣ Get shops from Express backend
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/shops'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load shops');
      }

      final shopJson = jsonDecode(response.body);
      final List shops = shopJson['shops'];
      print(shops);
      final List<String> availableShops = shops
          .map<String>((shop) => shop['name'].toString().toLowerCase())
          .toList();

      // 5️⃣ Build results + canOrder
      List<Map<String, dynamic>> results = [];

      for (final item in pricesList) {
        final shopName = item['source']?.toString() ?? '';
        print(availableShops.contains(shopName.toLowerCase()));

        results.add({
          "price": item['price'].toString(),
          "currency": item['currency'].toString(),
          "thumbnail": item['thumbnail'],
          "productLink": item['product_link'],
          "shopName": shopName,

          // 🔑 CORE LOGIC
          "canOrder": availableShops.contains(shopName.toLowerCase()),
          "shopWebsite": null,
          "shopAddress": null,
          "shopRating": null,
          "shopReviews": null,
          "shopPhone": null,
          "shopLocation": null,
          "googleMapsLink": null,
        });
      }

      // // 6️⃣ Enrich with Google Maps
      // await enrichResultsWithShopData(results, lat, lng);

      // // 7️⃣ Sort results
      // final sortedResults = sortResults(results);

      return {"model": sneakerModel, "results": results};
    } catch (e) {
      print("getProductData error: $e");
      rethrow;
    }
  }
}
