import 'package:flutter/material.dart';

class PopularSneakerCard extends StatelessWidget {
  final String title;
  final String imgPath;

  const PopularSneakerCard(this.title, this.imgPath, {super.key});

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
            // ⭐ FULL IMAGE, NO CROP, RESPONSIVE HEIGHT BASED ON RATIO
            AspectRatio(
              aspectRatio: 1, // Square card (you can modify if needed)
              child: Center(
                child: Image.asset(
                  imgPath,
                  fit: BoxFit.contain, // SHOW FULL IMAGE, NO CROP
                ),
              ),
            ),

            // ⭐ GRADIENT + TITLE
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(),
                child: Text(
                  title,
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
