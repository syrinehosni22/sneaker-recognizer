import 'package:image_picker/image_picker.dart';
import './sneaker_service_function/cloudinary_service.dart';
import './sneaker_service_function/openai_service.dart';
import './sneaker_service_function/location_service.dart';
import './sneaker_service_function/serpapi_shopping_service.dart';
import './sneaker_service_function/result_mapper.dart';
import './sneaker_service_function/membership_sort.dart';
import './sneaker_service_function/shop_name_enricher.dart';

class SneakerApiService {
  /// ─────────────────────────────────────────────────────────────────────────
  /// 1. IMAGE → AI identify → SerpAPI search → full pipeline
  /// ─────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getSneakerData(XFile image) async {
    // 1. Upload image to Cloudinary
    final imageUrl = await CloudinaryService.uploadImage(image);

    // 2. AI: identify sneaker model (brand + colorway)
    final model = await OpenAIService.identifySneaker(imageUrl);

    // 3. Optional: user location (for local pricing, not blocking)
    final position = await LocationService.getUserLocation().catchError(
      (_) => null,
    );

    // 4. SerpAPI shopping search
    final rawResults = await ProductSearchService.searchProducts(model);

    // 5. Map raw SerpAPI fields → standard Sneaker fields
    final mapped = ResultMapper.mapBase(rawResults);

    // 6. Enrich with shop name
    final enriched = ShopNameEnricher.addShopNames(mapped);

    // 7. Sort: partner shops first
    final sorted = sortByMembership(enriched);

    return {"model": model, "location": position, "results": sorted};
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// 2. TEXT SEARCH → SerpAPI → full pipeline
  /// ─────────────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> searchSneakerByName(String query) async {
    // 1. SerpAPI shopping search
    final rawResults = await ProductSearchService.searchProducts(query);

    // 2. Map raw fields
    final mapped = ResultMapper.mapBase(rawResults);

    // 3. Enrich shop names
    final enriched = ShopNameEnricher.addShopNames(mapped);

    // 4. Sort: partner shops first
    final sorted = sortByMembership(enriched);

    return {"model": query, "results": sorted};
  }
}
