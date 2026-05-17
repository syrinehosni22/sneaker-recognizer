import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:sneaker_recognizer_plateform/presentation/widgets/SneakerScan/SneakerScanButton.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/popular_sneaker_card.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/special_offer_card.dart';

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
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price'].toString()) ?? 0.0,
      category: (json['category'] ?? '').toString(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker picker = ImagePicker();

  XFile? _image;
  bool _loading = false;

  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // 📡 FETCH PRODUCTS
  Future<void> fetchProducts() async {
    try {
      setState(() => _loading = true);

      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        final parsed = data
            .whereType<Map<String, dynamic>>()
            .map((e) => Product.fromJson(e))
            .toList();

        setState(() {
          products = parsed;
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

  // 📸 PICK IMAGE
  Future<void> pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() => _image = pickedFile);
  }

  // ⭐ FEATURED PRODUCT
  Product? get featuredProduct => products.isNotEmpty ? products.first : null;

  // 🛡 SAFE IMAGE
  String safeImage(String url) {
    if (url.trim().isEmpty) {
      return 'https://via.placeholder.com/300x300.png?text=No+Image';
    }
    return url;
  }

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

                // SEARCH
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // IMAGE PREVIEW
                if (_image != null)
                  FutureBuilder<Uint8List>(
                    future: _image!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          snapshot.data!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 25),

                // SPECIAL OFFER
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

                // MOST POPULAR
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
            child: SneakerScanButton(onTap: pickImage),
          ),

          // LOADING
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
