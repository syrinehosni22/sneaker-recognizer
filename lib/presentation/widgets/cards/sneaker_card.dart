import 'package:flutter/material.dart';

class SneakerCard extends StatelessWidget {
  final String name;
  final String link; // ✅ single link
  final Function(String) onLinkTap;

  const SneakerCard({
    super.key,
    required this.name,
    required this.link,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Link as a single Chip
            GestureDetector(
              onTap: () => onLinkTap(link),
              child: Chip(
                label: Text(link, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
