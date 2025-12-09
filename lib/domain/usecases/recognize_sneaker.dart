import '../../data/repositories/sneaker_repository.dart';
import '../models/sneaker.dart';
import 'dart:io';

class RecognizeSneakerUseCase {
  final SneakerRepository repository = SneakerRepository();

  Future<Sneaker> execute(File image) async {
    final name = await repository.recognizeSneaker(image);
    final links = await repository.getSneakerLinks(name);
    return Sneaker(name: name, links: links);
  }
}
