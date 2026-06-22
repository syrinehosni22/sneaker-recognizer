class ShopNameEnricher {
  static List<Map<String, dynamic>> addShopNames(
    List<Map<String, dynamic>> results,
  ) {
    return results.map((item) {
      final shopName = _extract(item);
      return {...item, "shopName": shopName};
    }).toList();
  }

  static String _extract(Map<String, dynamic> item) {
    // After ResultMapper, the shop is in "shop".
    // Also keep fallbacks for raw SerpAPI fields just in case.
    final value =
        item["shop"] ??
        item["shopName"] ??
        item["source"] ??
        item["merchant"] ??
        item["seller"] ??
        item["store"];

    if (value == null || value.toString().trim().isEmpty) {
      return "Unknown store";
    }
    return value.toString().trim();
  }
}
