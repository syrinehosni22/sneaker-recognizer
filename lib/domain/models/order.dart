import 'cart_item.dart';

enum OrderType { delivery, pickup }

class Order {
  final List<CartItem> items;
  final OrderType type;
  final double deliveryFee;

  Order({required this.items, required this.type, this.deliveryFee = 0});

  double get subtotal => items.fold(0, (sum, item) => sum + item.price);
  double get total => subtotal + (type == OrderType.delivery ? deliveryFee : 0);
}
