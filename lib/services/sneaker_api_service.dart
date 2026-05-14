import 'package:image_picker/image_picker.dart';
import './sneaker_service_function/cloudinary_service.dart';
import './sneaker_service_function/openai_service.dart';
import './sneaker_service_function/location_service.dart';
import './sneaker_service_function/serpapi_shopping_service.dart';
import './sneaker_service_function/result_mapper.dart';
import './sneaker_service_function/membership_sort.dart';

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
    final results = ResultMapper.mapBase(rawResults);

    // 6 Sort by membership / priority
    final sortedResults = sortByMembership(results);

    return {"model": model, "location": position, "results": sortedResults};
  }

  /// ================================
  /// 2. TEXT SEARCH → SERPAPI
  /// ================================
  static Future<Map<String, dynamic>> searchSneakerByName(String query) async {
    final rawResults = await SerpApiShoppingService.searchProducts(query);

    final results = ResultMapper.mapBase(rawResults);

    final sortedResults = sortByMembership(results);

    return {"model": query, "results": sortedResults};
  }
}
