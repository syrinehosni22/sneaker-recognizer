import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:sneaker_recognizer_plateform/domain/models/cart_item.dart';
import 'package:sneaker_recognizer_plateform/providers/cart_provider.dart';
import 'package:sneaker_recognizer_plateform/services/payment_service.dart';

class ProductDetailPage extends StatelessWidget {
  final CartItem product;

  const ProductDetailPage({super.key, required this.product});

  Future<void> _pay(BuildContext context, int totalAmount) async {
    try {
      final clientSecret = await PaymentService.createPaymentIntent(
        totalAmount,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "Global Sneakers",
        ),
      );

      await Stripe.instance.presentPaymentSheet();

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
      appBar: AppBar(title: Text(product.name)),
      body: Column(
        children: [
          // Image.network(product.imageUrl, height: 250),
          const SizedBox(height: 16),
          Text(
            "\$${(product.price / 100).toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => cart.addItem(product),
            child: Text(inCart ? "Add More" : "Add to Cart"),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: cart.items.isEmpty
                ? null
                : () => _pay(context, cart.totalAmount),
            child: Text("Pay \$${(cart.totalAmount / 100).toStringAsFixed(2)}"),
          ),
        ],
      ),
    );
  }
}
