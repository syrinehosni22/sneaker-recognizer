import 'package:flutter/material.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/Product_card.dart';
import '../../../domain/models/product.dart';

class FavoritesScreen extends StatelessWidget {
  FavoritesScreen({super.key});

  final List<Product> favoriteProducts = [
    Product(
      id: "azerty12",
      name: "Nike Air Max",
      links: ["https://nike.com"],
      price: 85,
    ),
    Product(
      id: "azerty12",
      name: "Adidas Ultra Boost",
      links: ["https://adidas.com"],
      price: 95,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: favoriteProducts.isEmpty
          ? const Center(child: Text("No favorites yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                final Product = favoriteProducts[index];
                return ProductCard(
                  name: Product.name,
                  links: Product.links,
                  onLinkTap: (url) async {
                    // open link
                  },
                );
              },
            ),
    );
  }
}
