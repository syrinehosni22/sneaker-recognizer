class CartItem {
  final String id;
  final String name;
  final double price;
  final String? imageUrl;
  final String? description;
  final int review;

  final String? category;
  final String? brand;
  final bool isAvailable;

  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
    this.review = 0,
    this.category = "",
    this.brand = "",
    this.isAvailable = true,
    this.quantity = 1,
  });
}
