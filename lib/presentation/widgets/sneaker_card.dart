import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class SneakerCard extends StatelessWidget {
  final String name;
  final List<String> links;
  final void Function(String) onLinkTap;

  const SneakerCard({required this.name, required this.links, required this.onLinkTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...links.map((link) => InkWell(
                  onTap: () => onLinkTap(link),
                  child: Text(link, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                )),
          ],
        ),
      ),
    );
  }
}
