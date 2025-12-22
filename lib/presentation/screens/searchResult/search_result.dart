import 'package:flutter/material.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/search_result_card.dart';

class SneakerResultPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const SneakerResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final List elements = (result['results'] ?? []) as List;
    print(elements);
    return Scaffold(
      appBar: AppBar(title: const Text("Sneaker Results")),
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
              return ShopOfferCard(
                shopName: el["shopName"],
                price: el["price"],
                location: el["googleMapsLink"],
                shopUrl: el["shopWebsite"],
              );
              // open product_link if needed
            }),
        ],
      ),
    );
    // return Scaffold(body: const SizedBox());
  }
}
