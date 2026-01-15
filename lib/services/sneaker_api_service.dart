import 'package:image_picker/image_picker.dart';
import 'package:sneaker_recognizer_plateform/services/sneaker_service_function/membership_sort.dart';
import './sneaker_service_function/cloudinary_service.dart';
import './sneaker_service_function/openai_service.dart';
import './sneaker_service_function/location_service.dart';
import './sneaker_service_function/serpapi_shopping_service.dart';
import './sneaker_service_function/serpapi_maps_service.dart';
import './sneaker_service_function/result_mapper.dart';

class SneakerApiService {
  static Future<Map<String, dynamic>> getSneakerData(XFile image) async {
    // 1 Upload
    final imageUrl = await CloudinaryService.uploadImage(image);

    // 2 IA
    final model = await OpenAIService.identifySneaker(imageUrl);

    // 3 GPS
    final position = await LocationService.getUserLocation();

    // 4 Prices
    // get prices from the backend

    //
    // final raw = await googleSearchProducts(model);
    // final results = ResultMapper.mapBase(raw);

    //sort shops

    // final sortedResults = sortByMembership(results);

    // return {"model": model, "results": sortedResults};
    return {};
  }
}
