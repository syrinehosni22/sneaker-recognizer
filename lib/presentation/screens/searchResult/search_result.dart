import 'package:flutter/material.dart';
import 'package:sneaker_recognizer_plateform/domain/models/sneaker.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/search_result_card.dart';

class SneakerResultPage extends StatelessWidget {
  final List<Map<String, dynamic>> result; // ✅ List, pas Map

  const SneakerResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final List elements = (result ?? []) as List;
    print("result search");
    print(result);
    final List<Sneaker> sneakersList = elements
        .map((e) => Sneaker.fromJson(e))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Results")),
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
            ...sneakersList.map((el) {
              return ShopOfferCard(sneaker: el, allSneakers: sneakersList);
              // open product_link if needed
            }),
        ],
      ),
    );
    // return Scaffold(body: const SizedBox());
  }
}
