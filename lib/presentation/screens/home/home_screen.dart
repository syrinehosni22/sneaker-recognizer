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

  double safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

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

  Product? get featuredProduct => products.isNotEmpty ? products.first : null;

  String safeImage(String url) {
    if (url.trim().isEmpty) {
      return 'https://via.placeholder.com/300x300.png?text=No+Image';
    }
    return url;
  }

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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── App bar ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Discover',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          letterSpacing: -.6,
                        ),
                      ),
                      // Scan button
                      GestureDetector(
                        onTap: scanSneaker,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.document_scanner_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Search bar ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Search sneakers...',
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontSize: 15,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white54,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Special Offers label ─────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 32, 20, 14),
                  child: Text(
                    'Special Offers',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      letterSpacing: -.4,
                    ),
                  ),
                ),
              ),

              // ── Featured card ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: featuredProduct == null
                      ? _buildFeaturedSkeleton()
                      : _buildFeaturedCard(featuredProduct!),
                ),
              ),

              // ── Most Popular label ───────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 32, 20, 14),
                  child: Text(
                    'Most Popular',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      letterSpacing: -.4,
                    ),
                  ),
                ),
              ),

              // ── Horizontal product list ──────────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: products.isEmpty
                      ? _buildPopularSkeletons()
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _PopularCard(
                                title: product.title,
                                image: safeImage(product.image),
                                price: product.price,
                              ),
                            );
                          },
                        ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),

          // ── Loading overlay ──────────────────────────────────────────────
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Featured card ──────────────────────────────────────────────────────────
  Widget _buildFeaturedCard(Product product) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Product image with dark overlay
          Opacity(
            opacity: 0.45,
            child: Image.network(
              safeImage(product.image),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            ),
          ),
          // Text
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Special offer',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: -.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Skeletons ──────────────────────────────────────────────────────────────
  Widget _buildFeaturedSkeleton() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
    );
  }

  Widget _buildPopularSkeletons() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Popular card ──────────────────────────────────────────────────────────────

class _PopularCard extends StatefulWidget {
  final String title;
  final String image;
  final double price;

  const _PopularCard({
    required this.title,
    required this.image,
    required this.price,
  });

  @override
  State<_PopularCard> createState() => _PopularCardState();
}

class _PopularCardState extends State<_PopularCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 140,
        decoration: BoxDecoration(
          color: _pressed ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Image.network(
                widget.image,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade100,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.black26,
                  ),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _pressed ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _pressed ? Colors.white : Colors.black,
                    ),
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
