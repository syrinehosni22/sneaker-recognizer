import 'package:flutter/material.dart';
import '../../widgets/sneaker_card.dart';
import '../../../domain/models/sneaker.dart';

class FavoritesScreen extends StatelessWidget {
  FavoritesScreen({super.key});

  final List<Sneaker> favoriteSneakers = [
    Sneaker(name: "Nike Air Max", links: ["https://nike.com"]),
    Sneaker(name: "Adidas Ultra Boost", links: ["https://adidas.com"]),
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
                  name: sneaker.name,
                  links: sneaker.links,
                  onLinkTap: (url) async {
                    // open link
                  },
                );
              },
            ),
    );
  }
}
