import 'package:flutter/material.dart';
import 'package:sneaker_recognizer_plateform/domain/models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  void addItem(CartItem item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index].quantity += 1;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
