import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/models/sneaker.dart';
import '../../widgets/cards/sneaker_card.dart';
import '../../widgets/cards/special_offer_card.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  Sneaker? _sneaker;
  bool _loading = false;

  final picker = ImagePicker();
  final HomeController controller = HomeController();

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _sneaker = null;
      _loading = true;
    });

    final sneaker = await controller.recognize(_image!);

    setState(() {
      _sneaker = sneaker;
      _loading = false;
    });
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 SEARCH BAR
          TextField(
            decoration: InputDecoration(
              hintText: "Search sneakers...",
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

          // ⭐ SPECIAL OFFERS SECTION
          const Text(
            "Special Offers",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          SpecialOfferCard(
            imagePath: "assets/images/special_offer.jpg",
            title: "30% OFF on Nike Sneakers!",
            heightRatio: 0.45, // Adjust if you want (0.3, 0.4, 0.5…)
          ),

          const SizedBox(height: 30),

          // 🔥 MOST POPULAR SECTION
          const Text(
            "Most Popular",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _popularCard("Nike Air Max", "assets/images/nike-air-max.jpg"),
                _popularCard("Yeezy Boost", "assets/images/yeezy-bost.jpg"),
                _popularCard("Air Jordan 4", "assets/images/air-jordan-4.jpg"),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 🎯 MAIN FEATURE SECTION
          const Text(
            "Try Our AI Recognition",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black87,
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white, size: 40),
                    SizedBox(height: 10),
                    Text(
                      "Open Camera for Recognition",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // RESULT SECTION
          if (_image != null) ...[
            const Text(
              "Recognition Result",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Image.file(_image!, height: 200),
            const SizedBox(height: 20),
          ],

          if (_loading) const Center(child: CircularProgressIndicator()),

          if (_sneaker != null)
            SneakerCard(
              name: _sneaker!.name,
              links: _sneaker!.links,
              onLinkTap: _launchURL,
            ),
        ],
      ),
    );
  }

  // ⭐ Small popular item card
  Widget _popularCard(String title, String imgPath) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
        image: DecorationImage(image: AssetImage(imgPath), fit: BoxFit.cover),
      ),
      child: Container(
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
