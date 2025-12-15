import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SneakerScanButton extends StatelessWidget {
  final VoidCallback onTap;

  const SneakerScanButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 🔥 ONLY forward tap
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 12,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: SvgPicture.asset(
          'assets/icons/scan-shoes.svg',
          width: 60,
          height: 60,
        ),
      ),
    );
  }
}
