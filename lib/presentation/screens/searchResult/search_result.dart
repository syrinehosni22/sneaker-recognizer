import 'package:flutter/material.dart';
import 'package:sneaker_recognizer_plateform/domain/models/cart_item.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/search_result_card.dart';

class SneakerResultPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const SneakerResultPage({super.key, required this.result});

  /// Safely parse any value to double
  double parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();

    final cleaned = value
        .toString()
        .replaceAll(RegExp(r'[^\d,.-]'), '') // keep digits, dot, comma, minus
        .replaceAll(',', '.')
        .trim();

    return double.tryParse(cleaned) ?? 0.0;
  }

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
              // Create CartItem safely
              final CartItem product = CartItem(
                id: el['id']?.toString() ?? '',
                name: el['shopName'] ?? 'Unknown',
                price: parseToDouble(el['price']),
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