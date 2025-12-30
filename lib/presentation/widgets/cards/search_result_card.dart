import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopOfferCard extends StatelessWidget {
  final String? shopName;
  final String? price;
  final String? location;
  final String? shopUrl;

  const ShopOfferCard({
    super.key,
    this.shopName,
    this.price,
    this.location,
    this.shopUrl,
  });

  // Future<void> _openShop() async {
  //   if (shopUrl == null || shopUrl!.isEmpty) return;
  //   final uri = Uri.parse(shopUrl!);
  //   await launchUrl(uri, mode: LaunchMode.externalApplication);
  // }

  void _order() {
    print("order");
  }

  bool get hasButton => shopUrl != null && shopUrl!.isNotEmpty;

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
            /// LEFT SIDE: Shop name and price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (shopName != null && shopName!.isNotEmpty)
                    Text(
                      shopName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (price != null && price!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        price!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            /// RIGHT SIDE: Location icon and Shop button
            Row(
              children: [
                // if (location != null && location!.isNotEmpty)
                //   IconButton(
                //     icon: const Icon(Icons.location_on, color: Colors.grey),
                //     onPressed: () async {
                //       final uri = Uri.parse(
                //         "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location!)}",
                //       );
                //       if (await canLaunchUrl(uri)) {
                //         await launchUrl(
                //           uri,
                //           mode: LaunchMode.externalApplication,
                //         );
                //       }
                //     },
                //   ),
                // if (hasButton)
                //   SizedBox(
                //     height: 34,
                //     child: ElevatedButton(
                //       onPressed: _openShop,
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.black,
                //         elevation: 0,
                //         padding: const EdgeInsets.symmetric(horizontal: 12),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(10),
                //         ),
                //       ),
                //       child: Row(
                //         mainAxisSize: MainAxisSize.min,
                //         children: const [
                //           Text(
                //             "Shop",
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 13,
                //               fontWeight: FontWeight.w600,
                //             ),
                //           ),
                //           SizedBox(width: 6),
                //           Icon(
                //             Icons.arrow_forward,
                //             size: 14,
                //             color: Colors.white,
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                if (hasButton)
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: _order,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
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
                            "Order",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
