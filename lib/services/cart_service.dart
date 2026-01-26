import 'package:flutter/material.dart';
import '../domain/models/cart_item.dart';
import '../domain/models/product.dart';
import '../domain/models/order.dart';

class CartService with ChangeNotifier {
  final List<CartItem> _items = [];

  OrderType orderType = OrderType.delivery;
  double deliveryFee = 5.0;

  List<CartItem> get items => List.unmodifiable(_items);

  /// ADD Product
  void addProduct(Product product) {
    final index = _items.indexWhere((item) => item.id == product.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(
        CartItem(
          id: product.id,
          name: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          quantity: 1, // default when first added
        ),
      );
    }

    notifyListeners();
  }

  /// REMOVE Product
  void removeProduct(String productId) {
    _items.removeWhere((item) => item.id == productId);
    notifyListeners();
  }

  /// CHANGE DELIVERY / PICKUP
  void setOrderType(OrderType type) {
    orderType = type;
    notifyListeners();
  }

  /// TOTALS
  double get subtotal => _items.fold(0, (sum, item) => sum + item.price);

  double get total =>
      subtotal + (orderType == OrderType.delivery ? deliveryFee : 0);

  /// CREATE ORDER PAYLOAD (BACKEND)
  Map<String, dynamic> toOrderPayload() {
    return {
      "type": orderType.name,
      "deliveryFee": orderType == OrderType.delivery ? deliveryFee : 0,
      "items": _items
          .map(
            (e) => {
              "productId": e.id,
              "name": e.name,
              "quantity": e.quantity,
              "price": e.price,
            },
          )
          .toList(),
      "subtotal": subtotal,
      "total": total,
    };
  }

  /// CLEAR CART
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
