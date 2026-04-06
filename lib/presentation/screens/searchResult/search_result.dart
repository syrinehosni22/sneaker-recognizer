import 'package:flutter/material.dart';
import 'package:sneaker_recognizer_plateform/domain/models/cart_item.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/search_result_card.dart';

class SneakerResultPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const SneakerResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // Safely cast the results list from the API map.
    // If 'results' is null, it defaults to an empty list.
    final List elements = (result['results'] ?? []) as List;

    return Scaffold(
      backgroundColor:
          Colors.grey[50], // Slight background tint for better card contrast
      appBar: AppBar(
        title: const Text(
          "Product Results",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Available Offers",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Check if the list is empty
          if (elements.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "No elements found",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            // Map each element to a ShopOfferCard
            ...elements.map((el) {
              // FIX: Robust price parsing.
              // We check if it's a number, convert to double, otherwise default to 0.0.
              final dynamic rawPrice = el['extracted_price'];
              final double priceData = (rawPrice is num)
                  ? rawPrice.toDouble()
                  : 0.0;

              // Create the CartItem model with safe null-coalescing
              final CartItem product = CartItem(
                id: el['id']?.toString() ?? '',
                name: el['title'] ?? el['shopName'] ?? 'Unknown Product',
                price: priceData,
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
