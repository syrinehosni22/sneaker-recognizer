import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/sneaker.dart';
import '../../../services/cart_service.dart';
import '../cart/cart_page.dart';

class ProductDetailsPage extends StatelessWidget {
  final Sneaker sneaker;
  final List<Sneaker> allSneakers;

  const ProductDetailsPage({
    Key? key,
    required this.sneaker,
    required this.allSneakers,
  }) : super(key: key);

  void _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final similarProducts = allSneakers
        .where((s) => s.id != sneaker.id)
        .toList();

    final cart = context.read<CartService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(sneaker.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                sneaker.imageUrl ??
                    "https://via.placeholder.com/400x400.png?text=Sneaker",
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Text(
                    sneaker.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// PRICE (EURO)
                  Text(
                    "€${sneaker.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// SHOP
                  Text(
                    "Shop: ${sneaker.shopName}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),

                  const SizedBox(height: 12),

                  /// DESCRIPTION
                  Text(
                    sneaker.snippet ?? "",
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  /// BUTTONS
                  Row(
                    children: [
                      /// ADD TO CART
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            cart.addSneaker(sneaker);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Added to cart")),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text("Add to Cart"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// PAY NOW
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CartPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text("Pay"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// OPEN ORIGINAL LINK
                  if (sneaker.link != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _openLink(sneaker.link!),
                        child: const Text("View Original Product"),
                      ),
                    ),

                  const SizedBox(height: 30),

                  /// SIMILAR PRODUCTS
                  if (similarProducts.isNotEmpty) ...[
                    const Text(
                      "Similar Products",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: similarProducts.length,
                        itemBuilder: (context, index) {
                          final s = similarProducts[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailsPage(
                                    sneaker: s,
                                    allSneakers: allSneakers,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: 160,
                              margin: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      s.imageUrl ??
                                          "https://via.placeholder.com/160",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    s.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "€${s.price.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
