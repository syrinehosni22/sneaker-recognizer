import 'package:flutter/material.dart';

class SpecialOfferCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final double heightRatio;

  const SpecialOfferCard({
    super.key,
    required this.imagePath,
    required this.title,
    this.heightRatio = 0.3,
  });

  bool get isNetworkImage =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = screenWidth * heightRatio;

    return Container(
      height: cardHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.deepPurple.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ⭐ IMAGE (SAFE FOR API + ASSETS)
            isNetworkImage
                ? Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image, size: 50),
                  )
                : Image.asset(imagePath, fit: BoxFit.cover),

            // ⭐ DARK OVERLAY FOR TEXT READABILITY
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),

            // ⭐ TITLE
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
