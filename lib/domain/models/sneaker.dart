/// Domain model — matches exactly what ResultMapper + ShopNameEnricher produce.
class Sneaker {
  final String id;
  final String title;
  final double price;
  final String shopName;
  final String? productLink; // deep-link to the shop page
  final String? link; // fallback link field
  final String? snippet;
  final String? imageUrl; // serpapi_thumbnail (high-res)
  final String? thumbnail; // thumbnail (low-res fallback)
  final String? imageBase64;
  final bool isMember; // shop is a premium partner

  Sneaker({
    required this.id,
    required this.title,
    required this.price,
    required this.shopName,
    this.productLink,
    this.link,
    this.snippet,
    this.imageUrl,
    this.thumbnail,
    this.imageBase64,
    this.isMember = false,
  });

  /// Accepts both the raw SerpAPI shape and the already-mapped shape.
  factory Sneaker.fromJson(Map<String, dynamic> json) {
    return Sneaker(
      id: json['id']?.toString() ?? _generateId(json),
      title: json['title']?.toString() ?? '',
      price: _parsePrice(json['price']),
      shopName:
          json['shopName']?.toString() ??
          json['source']?.toString() ??
          'Unknown store',
      productLink:
          json['productLink']?.toString() ?? json['product_link']?.toString(),
      link: json['link']?.toString(),
      snippet: json['snippet']?.toString(),
      // prefer high-res serpapi_thumbnail mapped as imageUrl
      imageUrl:
          json['imageUrl']?.toString() ??
          json['serpapi_thumbnail']?.toString() ??
          json['thumbnail']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      imageBase64: json['image_base64']?.toString(),
      isMember: json['isMember'] == true,
    );
  }

  static String _generateId(Map<String, dynamic> json) =>
      '${json['title']}_${json['shopName']}_${json['price']}'.hashCode
          .toString();

  static double _parsePrice(dynamic value) {
    if (value == null) return 0;
    final cleaned = value
        .toString()
        .replaceAll(RegExp(r'[^\d.,]'), '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  String get priceEuro => '€${price.toStringAsFixed(2)}';

  /// Best available link to open the product.
  String? get shopUrl => productLink ?? link;
}
