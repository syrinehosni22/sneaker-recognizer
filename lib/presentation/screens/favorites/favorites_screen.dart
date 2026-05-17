import 'package:flutter/material.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/sneaker_card.dart';
import '../../widgets/cards/sneaker_card.dart';
import '../../../domain/models/sneaker.dart';

class FavoritesScreen extends StatelessWidget {
  FavoritesScreen({super.key});

  final List<Sneaker> favoriteSneakers = [
    Sneaker(
      id: "a.0",
      title: "Nike Air Force 1 White Sneakers - Amazon",
      price: 112.50,
      shopName: "amazon.fr",
      link: "https://www.amazon.fr/dp/B07HDF23A",
      snippet: "Nike Air Force 1 White. Prix €112.50. Expédié par Amazon.",
    ),
    Sneaker(
      id: "n.0",
      title: "Nike Air Force 1 07 White - Nike Official Store",
      price: 120.00,
      shopName: "nike.com",
      link: "https://www.nike.com/fr/t/air-force-1-07",
      snippet:
          "Nike Air Force 1 '07 White disponible sur le Nike Store officiel pour €120.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: favoriteSneakers.isEmpty
          ? const Center(child: Text("No favorites yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteSneakers.length,
              itemBuilder: (context, index) {
                final sneaker = favoriteSneakers[index];
                return SneakerCard(
                  name: sneaker.title,
                  link: sneaker.link.toString(),
                  onLinkTap: (url) async {
                    // open link
                  },
                );
              },
            ),
    );
  }
}
