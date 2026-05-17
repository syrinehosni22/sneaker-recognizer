class ShopNameEnricher {
  /// Extract shop name from SerpAPI result fields
  static List<Map<String, dynamic>> addShopNames(
    List<Map<String, dynamic>> results,
  ) {
    return results.map((item) {
      final shopName = _extractShopFromSerp(item);
      print(shopName);

      return {...item, "shopName": shopName};
    }).toList();
  }

  /// Try multiple SerpAPI fields safely
  static String _extractShopFromSerp(Map<String, dynamic> item) {
    // Most common SerpAPI fields
    final source = item["source"];
    final merchant = item["merchant"];
    final seller = item["seller"];
    final store = item["store"];
    final displayShop = item["shop"];

    // Priority order (best → fallback)
    final rawShop = source ?? merchant ?? seller ?? store ?? displayShop;

    if (rawShop == null) return "Unknown Shop";

    return rawShop.toString().trim();
  }
}
