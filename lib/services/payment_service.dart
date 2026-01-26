import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String baseUrl = "http://localhost:5000/api";

  static Future<String> createPaymentIntent(double amount) async {
    final response = await http.post(
      Uri.parse("$baseUrl/payment/create-intent"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"amount": amount, "currency": "eur"}),
    );

    final data = jsonDecode(response.body);
    return data["clientSecret"];
  }
}
