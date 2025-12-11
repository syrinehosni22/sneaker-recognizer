import 'package:flutter/material.dart';

class SpecialOfferCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final double heightRatio; // ex: 0.25 → 25% of screen height

  const SpecialOfferCard({
    super.key,
    required this.imagePath,
    required this.title,
    this.heightRatio = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = screenWidth * heightRatio; // Responsive ratio

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.deepPurple.withOpacity(0.1),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.bottomLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 8)],
          ),
        ),
      ),
    );
  }
}
