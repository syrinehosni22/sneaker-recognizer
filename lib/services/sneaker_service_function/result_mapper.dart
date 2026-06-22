/// Maps raw SerpAPI shopping result fields to a clean, consistent structure
/// that matches the Sneaker model.
class ResultMapper {
  static List<Map<String, dynamic>> mapBase(List<dynamic> raw) {
    return raw.map((item) {
      return {
        // Required
        "title": item['title']?.toString() ?? '',
        "price": item['price'],

        // Shop identity
        "shopName":
            item['shop']?.toString() ?? item['source']?.toString() ?? '',

        // Links
        "productLink":
            item['product_link']?.toString() ?? item['link']?.toString() ?? '',
        "link": item['link']?.toString() ?? '',

        // Images — prefer high-res serpapi_thumbnail
        "imageUrl":
            item['image_url']?.toString() ??
            item['serpapi_thumbnail']?.toString() ??
            item['thumbnail']?.toString() ??
            '',
        "thumbnail": item['thumbnail']?.toString() ?? '',

        // Debug / ranking
        "score": item['score'],
      };
    }).toList();
  }
}
