class ResultMapper {
  static List<Map<String, dynamic>> mapBase(List<dynamic> raw) {
    return raw.map((item) {
      return {
        "price": item['price'],
        "thumbnail": item['thumbnail'],
        "shopName": item["shop"],
        "productLink": item['product_link'],
        "imageUrl": item["image_url"],
      };
    }).toList();
  }
}
