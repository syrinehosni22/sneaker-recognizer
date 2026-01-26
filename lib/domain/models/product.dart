class Product {
  final String id;
  final String name;
  final List<String> links;
  final double price;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.links,
    required this.price,
    this.imageUrl,
  });
}
