import 'package:flutter/material.dart';
import 'package:sneaker_recognizer_plateform/domain/models/cart_item.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/search_result_card.dart';

class SneakerResultPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const SneakerResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final List elements = (result['results'] ?? []) as List;
    print(elements);

    return Scaffold(
      appBar: AppBar(title: const Text("Product Results")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Prices",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (elements.isEmpty)
            const Text("No elements found")
          else
            ...elements.map((el) {
              // Assuming each 'el' is a Map<String, dynamic> with 'id', 'name', 'price', etc.
              final CartItem product = CartItem(
                id: el['id']?.toString() ?? '',
                name: el['shopName'] ?? 'Unknown',
                price: double.parse(
                  el['price'].replaceAll("€", "").replaceAll(",", ".").trim(),
                ),
                imageUrl: el['thumbnail'] ?? '',
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ShopOfferCard(product: product, canOrder: true),
              );
            }).toList(),
        ],
      ),
    );
  }
}
