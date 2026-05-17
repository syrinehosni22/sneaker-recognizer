import 'package:flutter/material.dart';
import '../domain/models/cart_item.dart';
import '../domain/models/sneaker.dart';
import '../domain/models/order.dart';

class CartService with ChangeNotifier {
  final List<CartItem> _items = [];

  OrderType orderType = OrderType.delivery;
  double deliveryFee = 5.0;

  List<CartItem> get items => List.unmodifiable(_items);

  /// ADD SNEAKER
  void addSneaker(Sneaker sneaker) {
    final index = _items.indexWhere((item) => item.sneaker.id == sneaker.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(sneaker: sneaker, quantity: 1));
    }

    notifyListeners();
  }

  /// REMOVE ITEM COMPLETELY
  void removeSneaker(String sneakerId) {
    _items.removeWhere((item) => item.sneaker.id == sneakerId);
    notifyListeners();
  }

  /// DECREASE QUANTITY
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

  void increaseQuantity(String sneakerId) {
    final index = _items.indexWhere((item) => item.sneaker.id == sneakerId);

    if (index != -1) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void setOrderType(OrderType type) {
    orderType = type;
    notifyListeners();
  }

  double get subtotal => _items.fold(0, (sum, item) => sum + item.total);

  double get total =>
      subtotal + (orderType == OrderType.delivery ? deliveryFee : 0);

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

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
