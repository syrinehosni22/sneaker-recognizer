import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:sneaker_recognizer_plateform/presentation/screens/searchResult/search_result.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/SneakerScan/SneakerScanButton.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/popular_sneaker_card.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/special_offer_card.dart';
import 'package:sneaker_recognizer_plateform/services/sneaker_api_service.dart';

// ================= PRODUCT MODEL =================
class Product {
  final int id;
  final String title;
  final String image;
  final double price;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: (json['title'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      price: json['price'] == null
          ? 0.0
          : double.tryParse(json['price'].toString()) ?? 0.0,
      category: (json['category'] ?? '').toString(),
    );
  }
}

// ================= HOME SCREEN =================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;

  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // ================= SAFE DOUBLE =================
  double safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // ================= FETCH PRODUCTS =================
  Future<void> fetchProducts() async {
    try {
      setState(() => _loading = true);

      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          products = data.map((e) => Product.fromJson(e)).toList();
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint("API error: $e");
      setState(() => _loading = false);
    }
  }

  // ================= FEATURED PRODUCT =================
  Product? get featuredProduct => products.isNotEmpty ? products.first : null;

  // ================= SAFE IMAGE =================
  String safeImage(String url) {
    if (url.trim().isEmpty) {
      return 'https://via.placeholder.com/300x300.png?text=No+Image';
    }
    return url;
  }

  // ================= AI SCAN =================
  Future<void> scanSneaker() async {
    try {
      setState(() => _loading = true);

      final picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() => _loading = false);
        return;
      }

      final result = await SneakerApiService.getSneakerData(image);

      final rawResults = (result['results'] ?? []) as List;

      setState(() => _loading = false);

      if (rawResults.isEmpty) return;

      final List<Map<String, dynamic>> safeResults = rawResults
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SneakerResultPage(result: safeResults),
        ),
      );
    } catch (e) {
      debugPrint("Scan error: $e");
      setState(() => _loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),

                // SEARCH BAR
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search sneakers...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // SPECIAL OFFERS
                const Text(
                  'Special Offers',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                featuredProduct == null
                    ? const Center(child: CircularProgressIndicator())
                    : SpecialOfferCard(
                        imagePath: safeImage(featuredProduct!.image),
                        title:
                            '${featuredProduct!.title} - \$${featuredProduct!.price}',
                        heightRatio: 0.7,
                      ),

                const SizedBox(height: 30),

                // POPULAR
                const Text(
                  'Most Popular',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 220,
                  child: products.isEmpty
                      ? const Center(child: Text('No products found'))
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];

                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: PopularSneakerCard(
                                product.title,
                                safeImage(product.image),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // SCAN BUTTON
          Positioned(
            top: 20,
            right: 20,
            child: SneakerScanButton(onTap: scanSneaker),
          ),

          // LOADING OVERLAY
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
