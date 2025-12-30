import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/cart_service.dart';

class OrderService {
  static const String baseUrl = "https://api.yourbackend.com";

  Future<String> createOrderAndPayment({
    required CartService cart,
    required String token,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/orders"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(cart.toOrderPayload()),
    );

    if (res.statusCode != 200) {
      throw Exception("Order creation failed");
    }

    /// Backend returns Stripe payment URL or clientSecret
    return jsonDecode(res.body)["paymentUrl"];
  }
}
