import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 1. Import the intl package
import 'package:sneaker_recognizer_plateform/domain/models/cart_item.dart';
import 'package:sneaker_recognizer_plateform/presentation/screens/product/product_detail_page.dart';

class ShopOfferCard extends StatelessWidget {
  final CartItem product;
  final bool canOrder;

  const ShopOfferCard({
    super.key,
    required this.product,
    this.canOrder = false,
  });

  void _order(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailPage(product: product)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 2. Create the formatter
    // 'de_DE' yields 1.250,00 € | 'en_IE' yields €1,250.00
    final formatter = NumberFormat.currency(
      locale: 'de_DE',
      symbol: '€',
      decimalDigits: 2,
    );

    return Card(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.name.isNotEmpty)
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      // 3. Apply the formatter here
                      formatter.format(product.price),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w600, // Slightly bolder for readability
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (canOrder)
              SizedBox(
                height: 34,
                child: ElevatedButton(
                  onPressed: () => _order(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Order",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
