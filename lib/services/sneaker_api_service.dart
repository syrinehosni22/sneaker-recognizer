import 'package:image_picker/image_picker.dart';
import './sneaker_service_function/cloudinary_service.dart';
import './sneaker_service_function/openai_service.dart';
import './sneaker_service_function/location_service.dart';
import './sneaker_service_function/serpapi_shopping_service.dart';
import './sneaker_service_function/result_mapper.dart';
import './sneaker_service_function/membership_sort.dart';
import './sneaker_service_function/shop_name_enricher.dart';

class SneakerApiService {
  /// ================================
  /// 1. IMAGE → AI + FULL PIPELINE
  /// ================================
  static Future<Map<String, dynamic>> getSneakerData(XFile image) async {
    // 1 Upload image
    final imageUrl = await CloudinaryService.uploadImage(image);

    // 2 AI detect sneaker model
    final model = await OpenAIService.identifySneaker(imageUrl);

    // 3 Get user location
    final position = await LocationService.getUserLocation();

    // 4 SerpAPI product search
    final rawResults = await SerpApiShoppingService.searchProducts(model);

    // 5 Map results
    final mappedResults = ResultMapper.mapBase(rawResults);

    // 6 Add shop names
    //    final enrichedResults = ShopNameEnricher.addShopNames(mappedResults);

    // 7 Sort by membership / priority
    final sortedResults = sortByMembership(mappedResults);

    return {"model": model, "location": position, "results": sortedResults};
  }

  /// ================================
  /// 2. TEXT SEARCH → SERPAPI
  /// ================================
  static Future<Map<String, dynamic>> searchSneakerByName(String query) async {
    final rawResults = await SerpApiShoppingService.searchProducts(query);

    // Map results
    //final mappedResults = ResultMapper.mapBase(rawResults);

    // Add shop names
    //final enrichedResults = ShopNameEnricher.addShopNames(mappedResults);

    // Sort results
    //final sortedResults = sortByMembership(rawResults);

    return {"model": query, "results": rawResults};
  }
}
