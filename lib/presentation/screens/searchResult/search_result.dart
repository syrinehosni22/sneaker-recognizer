import 'package:flutter/material.dart';

class SneakerResultPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const SneakerResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Result")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result['name'] ?? 'Unknown Sneaker',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Brand: ${result['brand'] ?? 'N/A'}"),
            const SizedBox(height: 10),
            Text("Confidence: ${result['confidence'] ?? '--'}%"),
          ],
        ),
      ),
    );
  }
}
