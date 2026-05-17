import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/models/sneaker.dart';

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
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Find similar products in the same shop or category if needed
    final similarProducts = allSneakers
        .where((s) => s.title != sneaker.title)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(sneaker.title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// PRODUCT IMAGE (placeholder if no image URL)
              /// PRODUCT IMAGE
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  sneaker.imageUrl ??
                      "https://via.placeholder.com/400x400.png?text=Sneaker",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      "https://via.placeholder.com/400x400.png?text=Sneaker",
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              /// TITLE
              Text(
                sneaker.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// PRICE
              Text(
                sneaker.price.toString(),
                style: const TextStyle(fontSize: 22, color: Colors.green),
              ),

              const SizedBox(height: 8),

              /// SHOP
              Text(
                "Shop: ${sneaker.shopName}",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 12),

              /// DESCRIPTION / SNIPPET
              Text(sneaker.snippet ?? "", style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 20),

              /// OPEN PRODUCT LINK
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (sneaker.link != null) _openLink(sneaker.link!);
                  },
                  child: const Text("View Product"),
                ),
              ),

              const SizedBox(height: 30),

              /// SIMILAR PRODUCTS
              if (similarProducts.isNotEmpty) ...[
                const Text(
                  "Similar Products",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                                  "https://via.placeholder.com/160x160.png?text=Sneaker",
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
                                s.price.toString(),
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
      ),
    );
  }
}
