import 'package:flutter/material.dart';

class PopularSneakerCard extends StatelessWidget {
  final String title;
  final String imgPath;

  const PopularSneakerCard(this.title, this.imgPath, {super.key});

  bool get isNetworkImage =>
      imgPath.startsWith('http://') || imgPath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 130;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // ⭐ IMAGE (NETWORK OR ASSET SAFE)
            AspectRatio(
              aspectRatio: 1,
              child: Center(
                child: isNetworkImage
                    ? Image.network(
                        imgPath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image, size: 40),
                      )
                    : Image.asset(imgPath, fit: BoxFit.contain),
              ),
            ),

            // ⭐ TITLE OVERLAY
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
