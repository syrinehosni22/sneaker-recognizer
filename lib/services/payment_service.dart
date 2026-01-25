import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String baseUrl = "http://10.0.2.2:5000";

  static Future<String> createPaymentIntent(int amount) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/payment/create-intent"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"amount": amount, "currency": "usd"}),
    );

    final data = jsonDecode(response.body);
    return data["clientSecret"];
  }
}
