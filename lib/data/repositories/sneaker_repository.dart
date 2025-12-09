import 'dart:io';
import '../api/openai_api.dart';
import '../api/google_search_api.dart';

class SneakerRepository {
  final OpenAIApi openAIApi = OpenAIApi();
  final GoogleSearchApi googleSearchApi = GoogleSearchApi();

  Future<String> recognizeSneaker(File image) async {
    return await openAIApi.recognizeSneaker(image);
  }

  Future<List<String>> getSneakerLinks(String sneakerName) async {
    return await googleSearchApi.searchLinks(sneakerName);
  }
}
