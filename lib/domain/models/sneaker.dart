class Sneaker {
  final String title;
  final double price;
  final String shop;
  final String? link;
  final String? snippet;

  /// Optional image sources
  final String? imageUrl;
  final String? imageBase64;

  Sneaker({
    required this.title,
    required this.price,
    required this.shop,
    this.link,
    this.snippet,
    this.imageUrl,
    this.imageBase64,
  });

  factory Sneaker.fromJson(Map<String, dynamic> json) {
    return Sneaker(
      title: json['title'] ?? '',
      price: _parsePrice(json['price']),
      shop: json['shop'] ?? '',
      link: json['link'],
      snippet: json['snippet'],
      imageUrl: json['image_url'],
      imageBase64: json['image_base64'],
    );
  }

  /// Converts "€119.99", "119,99", or 119.99 → 119.99
  static double _parsePrice(dynamic value) {
    if (value == null) return 0;
    final cleaned = value
        .toString()
        .replaceAll(RegExp(r'[^\d.,]'), '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }
}
