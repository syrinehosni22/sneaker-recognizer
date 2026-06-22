import 'package:flutter/material.dart';
import 'package:sneaker_recognizer_plateform/core/constants/colors.dart';
import 'package:sneaker_recognizer_plateform/domain/models/sneaker.dart';
import 'package:sneaker_recognizer_plateform/presentation/screens/productDetails/details.dart';

class ShopOfferCard extends StatelessWidget {
  final Sneaker sneaker;
  final List<Sneaker> allSneakers;

  const ShopOfferCard({
    super.key,
    required this.sneaker,
    required this.allSneakers,
  });

  void _moreDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProductDetailsPage(sneaker: sneaker, allSneakers: allSneakers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// SHOP + PRICE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sneaker.shopName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "\$${sneaker.price}",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          /// ORDER BUTTON
          ElevatedButton(
            onPressed: () => _moreDetails(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButton,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Order",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
