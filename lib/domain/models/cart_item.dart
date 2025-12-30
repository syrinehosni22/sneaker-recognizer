import 'sneaker.dart';

class CartItem {
  final Sneaker sneaker;
  int quantity;

  CartItem({required this.sneaker, this.quantity = 1});

  double get total => sneaker.price * quantity;
}
