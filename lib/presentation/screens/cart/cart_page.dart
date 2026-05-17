import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/cart_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartService>();

    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),

      body: cart.items.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: Image.network(
                            item.sneaker.imageUrl ??
                                "https://via.placeholder.com/80",
                            width: 60,
                            fit: BoxFit.cover,
                          ),

                          title: Text(item.sneaker.title),

                          subtitle: Text(
                            "€${item.sneaker.price.toStringAsFixed(2)}",
                          ),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () =>
                                    cart.decreaseQuantity(item.sneaker.id),
                              ),

                              Text("${item.quantity}"),

                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () =>
                                    cart.increaseQuantity(item.sneaker.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// TOTAL SECTION
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.grey)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Subtotal"),
                          Text("€${cart.subtotal.toStringAsFixed(2)}"),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "€${cart.total.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final payload = cart.toOrderPayload();
                            debugPrint(payload.toString());

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Order sent!")),
                            );
                          },
                          child: const Text("Checkout"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
