import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sneaker_recognizer_plateform/core/constants/api_constants.dart';

class PaymentService {
  static const String baseUrl = "${ApiConstants.baseUrl}/api";

  // We change return type to Map to capture all keys from the backend
  static Future<Map<String, dynamic>> createPaymentIntent(double amount) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/payment/create-intent"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"amount": amount, "currency": "eur"}),
      );

      final data = jsonDecode(response.body);
      print(data);
      if (response.statusCode == 200 && data["success"] == true) {
        // Return the full map to the UI controller
        return {
          "paymentIntent": data["paymentIntent"], // Matches your Node.js key
          "ephemeralKey": data["ephemeralKey"], // Matches your Node.js key
          "customer": data["customer"], // Matches your Node.js key
        };
      } else {
        throw Exception(data['message'] ?? "Server error occurred");
      }
    } catch (e) {
      throw Exception("Failed to connect to payment server: $e");
    }
  }
}
