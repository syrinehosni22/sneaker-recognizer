import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/cart_service.dart';
import 'package:sneaker_recognizer_plateform/core/constants/api_constants.dart';

class OrderService {
  Future<String> createOrderAndPayment({
    required CartService cart,
    required String token,
  }) async {
    final res = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/api/orders"),
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
