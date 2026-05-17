class Sneaker {
  final String id; // 🔥 IMPORTANT for cart operations
  final String title;
  final double price;
  final String shopName;
  final String? link;
  final String? snippet;

  /// Optional image sources
  final String? imageUrl;
  final String? imageBase64;

  Sneaker({
    required this.id,
    required this.title,
    required this.price,
    required this.shopName,
    this.link,
    this.snippet,
    this.imageUrl,
    this.imageBase64,
  });

  factory Sneaker.fromJson(Map<String, dynamic> json) {
    return Sneaker(
      id: json['id']?.toString() ?? _generateId(json),
      title: json['title'] ?? '',
      price: _parsePrice(json['price']),
      shopName: json['shopName'] ?? 'Unknown store',
      link: json['link'],
      snippet: json['snippet'],
      imageUrl: json['imageUrl'],
      imageBase64: json['image_base64'],
    );
  }

  /// If API has no ID → fallback generator
  static String _generateId(Map<String, dynamic> json) {
    return "${json['title']}_${json['shopName']}_${json['price']}".hashCode
        .toString();
  }

  /// Converts "€119.99", "119,99", "119" → 119.99
  static double _parsePrice(dynamic value) {
    if (value == null) return 0;

    final cleaned = value
        .toString()
        .replaceAll(RegExp(r'[^\d.,]'), '')
        .replaceAll(',', '.');

    return double.tryParse(cleaned) ?? 0;
  }

  /// Helper: formatted price in Euro
  String get priceEuro => "€${price.toStringAsFixed(2)}";
}
