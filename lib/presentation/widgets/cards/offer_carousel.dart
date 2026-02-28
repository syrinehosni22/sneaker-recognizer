import 'dart:async';
import 'package:flutter/material.dart';
import '../../../domain/models/Offer.dart';
import '../../widgets/cards/special_offer_card.dart';
import '../../../services/offer_service.dart';

class DynamicOfferCarousel extends StatefulWidget {
  const DynamicOfferCarousel({super.key});

  @override
  _DynamicOfferCarouselState createState() => _DynamicOfferCarouselState();
}

class _DynamicOfferCarouselState extends State<DynamicOfferCarousel> {
  // Changed from 'late' to nullable to prevent initialization errors
  Future<List<Offer>>? _futureOffers;
  final PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
    // The token is already inside OfferService._token thanks to AuthService
    _futureOffers = OfferService.fetchOffers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Offer>>(
      future: _futureOffers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        } else if (snapshot.hasError) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text("Unable to load current deals")),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final offers = snapshot.data!;

        return SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: offers.length,
            onPageChanged: (index) {
              // Optional: Update page indicators here
            },
            itemBuilder: (context, index) {
              final offer = offers[index];
              return SpecialOfferCard(
                title: "${offer.discountPercentage}% OFF: ${offer.title}",
                imagePath: "assets/images/promo_banner.jpg",
                heightRatio: 0.7,
              );
            },
          ),
        );
      },
    );
  }
}