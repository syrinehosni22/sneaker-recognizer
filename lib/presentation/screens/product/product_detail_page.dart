import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_recognizer_plateform/domain/models/cart_item.dart';
import 'package:sneaker_recognizer_plateform/providers/cart_provider.dart';
import 'package:sneaker_recognizer_plateform/services/payment_service.dart';

class ProductDetailPage extends StatelessWidget {
  final CartItem product;

  const ProductDetailPage({super.key, required this.product});

  Future<void> _pay(BuildContext context, double totalAmount) async {
    try {
      final clientSecret = await PaymentService.createPaymentIntent(
        totalAmount,
      );

      // await Stripe.instance.initPaymentSheet(
      //   paymentSheetParameters: SetupPaymentSheetParameters(
      //     paymentIntentClientSecret: clientSecret,
      //     merchantDisplayName: "IOMall",
      //   ),
      // );

      // await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Payment successful")));

      Provider.of<CartProvider>(context, listen: false).clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Payment failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final inCart = cart.items.any((i) => i.id == product.id);

    return Scaffold(
      appBar: AppBar(title: Text(product.name), centerTitle: true),

      /// 🔽 Bottom bar
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: product.isAvailable
                      ? () => cart.addItem(product)
                      : null,
                  icon: const Icon(Icons.shopping_cart),
                  label: Text(inCart ? "Add More" : "Add to Cart"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: cart.items.isEmpty
                      ? null
                      : () => _pay(context, cart.totalAmount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    "Pay €${cart.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      /// 🔽 Page content
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🖼 Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 260,
                width: double.infinity,
                child: Image.network(
                  product.imageUrl ?? 'https://via.placeholder.com/400',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 80),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// 🏷 Name + price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "€${product.price.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// ⭐ Rating
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(product.review.toString()),
              ],
            ),

            const SizedBox(height: 16),

            /// 📦 Availability badge
            Chip(
              label: Text(
                product.isAvailable ? "In Stock" : "Out of Stock",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: product.isAvailable ? Colors.green : Colors.red,
            ),

            const SizedBox(height: 24),

            /// 📝 Description
            const Text(
              "Description",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              product.description ?? "No description available.",
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 24),

            /// 📦 Details
            const Text(
              "Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _detailRow("Brand", product.brand),
            _detailRow("Category", product.category),
            _detailRow(
              "Availability",
              product.isAvailable ? "In Stock" : "Out of Stock",
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String? label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label ?? "", style: const TextStyle(color: Colors.grey)),
          Text(
            value ?? "",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
