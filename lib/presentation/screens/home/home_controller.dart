import 'dart:io';
import '../../../domain/usecases/recognize_sneaker.dart';
import '../../../domain/models/sneaker.dart';
import '../../../core/utils/logger.dart';

class HomeController {
  final RecognizeSneakerUseCase useCase = RecognizeSneakerUseCase();

  Future<Sneaker?> recognize(File image) async {
    try {
      Logger.log("Starting sneaker recognition...");
      final sneaker = await useCase.execute(image);
      Logger.log("Sneaker recognized: ${sneaker.name}");
      return sneaker;
    } catch (e) {
      Logger.log("Error: $e");
      return null;
    }
  }
}
