import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../domain/models/cart_item.dart';
import '../domain/models/sneaker.dart';
import '../domain/models/order.dart';

class CartService with ChangeNotifier {
  final List<CartItem> _items = [];

  OrderType orderType = OrderType.delivery;
  double deliveryFee = 5.0;

  List<CartItem> get items => List.unmodifiable(_items);

  /// =========================
  /// PAYMENT API
  /// =========================
  static Future<bool> payOrder(double amount) async {
    try {
      final response = await http.post(
        Uri.parse("http://92.222.243.150:5000/api/payment/create-intent"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"amount": amount, "currency": "eur"}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        // Stripe keys (for later PaymentSheet)
        final clientSecret = data["clientSecret"];
        final ephemeralKey = data["ephemeralKey"];
        final customerId = data["customerId"];

        debugPrint("clientSecret: $clientSecret");
        debugPrint("ephemeralKey: $ephemeralKey");
        debugPrint("customerId: $customerId");

        return true;
      }

      return false;
    } catch (e) {
      debugPrint("Payment error: $e");
      return false;
    }
  }

  /// =========================
  /// ADD ITEM
  /// =========================
  void addSneaker(Sneaker sneaker) {
    final index = _items.indexWhere((item) => item.sneaker.id == sneaker.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(sneaker: sneaker, quantity: 1));
    }

    notifyListeners();
  }

  /// =========================
  /// REMOVE ITEM
  /// =========================
  void removeSneaker(String sneakerId) {
    _items.removeWhere((item) => item.sneaker.id == sneakerId);
    notifyListeners();
  }

  /// =========================
  /// DECREASE QUANTITY
  /// =========================
  void decreaseQuantity(String sneakerId) {
    final index = _items.indexWhere((item) => item.sneaker.id == sneakerId);

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  /// =========================
  /// INCREASE QUANTITY
  /// =========================
  void increaseQuantity(String sneakerId) {
    final index = _items.indexWhere((item) => item.sneaker.id == sneakerId);

    if (index != -1) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  /// =========================
  /// ORDER TYPE
  /// =========================
  void setOrderType(OrderType type) {
    orderType = type;
    notifyListeners();
  }

  /// =========================
  /// CALCULATIONS
  /// =========================
  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);

  double get total =>
      subtotal + (orderType == OrderType.delivery ? deliveryFee : 0);

  /// =========================
  /// BUILD ORDER PAYLOAD
  /// =========================
  Map<String, dynamic> toOrderPayload() {
    return {
      "type": orderType.name,
      "deliveryFee": orderType == OrderType.delivery ? deliveryFee : 0,
      "items": _items
          .map(
            (e) => {
              "name": e.sneaker.title,
              "quantity": e.quantity,
              "price": e.sneaker.price,
            },
          )
          .toList(),
      "subtotal": subtotal,
      "total": total,
    };
  }

  /// =========================
  /// CLEAR CART
  /// =========================
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
