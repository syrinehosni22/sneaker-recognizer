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

  /// 🔗 Redirect to product details
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
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// =========================
            /// PRODUCT ICON
            /// =========================
            Container(
              width: 54,
              height: 54,

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),

              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 26,
                color: Colors.black87,
              ),
            ),

            const SizedBox(width: 14),

            /// =========================
            /// PRODUCT INFO
            /// =========================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// PRODUCT NAME
                  Text(
                    sneaker.title,

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// PRICE
                  Text(
                    sneaker.price != 0
                        ? "€${sneaker.price}"
                        : "Price unavailable",

                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: sneaker.price != 0
                          ? Colors.green.shade700
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            /// =========================
            /// ORDER BUTTON
            /// =========================
            ElevatedButton(
              onPressed: () => _moreDetails(context),

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,

                elevation: 0,

                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    "Order",

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(width: 6),

                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
