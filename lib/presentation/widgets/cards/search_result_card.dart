import 'package:flutter/material.dart';
import 'package:sneaker_recognizer_plateform/core/constants/colors.dart';
import 'package:sneaker_recognizer_plateform/domain/models/sneaker.dart';
import 'package:sneaker_recognizer_plateform/presentation/screens/productDetails/details.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopOfferCard extends StatelessWidget {
  final Sneaker sneaker;
  final List<Sneaker> allSneakers;

  const ShopOfferCard({
    super.key,
    required this.sneaker,
    required this.allSneakers,
  });

  /// Redirect to the product page
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
    return Card(
      color: Colors.white,
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            /// LEFT SIDE: Shop name & price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sneaker.title.isNotEmpty)
                    Text(
                      sneaker.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (sneaker.price != 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "€" + sneaker.price.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  if (sneaker.shop.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        sneaker.shop,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            /// RIGHT SIDE: More details button
            SizedBox(
              height: 34,
              child: ElevatedButton(
                onPressed: () => _moreDetails(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "View",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.open_in_new, size: 14, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
