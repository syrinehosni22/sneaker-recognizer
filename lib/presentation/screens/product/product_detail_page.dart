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
      // 1. Fetch data from your backend
      // Ensure PaymentService uses 10.0.2.2 for Android debugging!
      final Map<String, dynamic> paymentData =
          await PaymentService.createPaymentIntent(totalAmount);

      // 2. Initialize the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentData['paymentIntent'],
          customerEphemeralKeySecret: paymentData['ephemeralKey'],
          customerId: paymentData['customer'],
          merchantDisplayName: 'Sneaker Recognizer',
          // Set to true if you want to support Apple/Google Pay
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'FR'),
          googlePay: const PaymentSheetGooglePay(merchantCountryCode: 'FR'),
          style: ThemeMode.system,
        ),
      );

      // 3. Display the Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Success handling
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Payment successful")));

      Provider.of<CartProvider>(context, listen: false).clear();

      // TODO: Navigator.of(context).pushNamed('/dashboard');
    } catch (e) {
      if (e is StripeException) {
        // Handle "User cancelled" specifically so you don't show a scary red error
        if (e.error.code == FailureCode.Canceled) {
          debugPrint("User cancelled the payment");
          return;
        }
        _showError(context, "Stripe Error: ${e.error.localizedMessage}");
      } else {
        debugPrint("General Error: $e");
        _showError(context, "Connection failed. Please check your internet.");
      }
    }
  }

  // Helper for cleaner code
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
