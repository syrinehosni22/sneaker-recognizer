import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sneaker_recognizer_plateform/presentation/screens/searchResult/search_result.dart';
import 'dart:typed_data';
import 'package:sneaker_recognizer_plateform/presentation/widgets/SneakerScan/SneakerScanButton.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/popular_sneaker_card.dart';
import 'package:sneaker_recognizer_plateform/presentation/widgets/cards/special_offer_card.dart';
import 'package:sneaker_recognizer_plateform/services/sneaker_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? _image;
  bool _loading = false;

  final picker = ImagePicker();

  // 📸 Pick image
  Future<void> pickImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() {
      _image = pickedFile; // store XFile instead of File
      _loading = true;
    });

    await sendImageAndNavigate(pickedFile);
  }

  Future<void> sendImageAndNavigate(XFile image) async {
    try {
      setState(() => _loading = true);

      final data = await SneakerApiService.getProductData(image);

      setState(() => _loading = false);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SneakerResultPage(result: data)),
      );
    } catch (e) {
      setState(() => _loading = false);
      debugPrint("Request failed: $e");
    }
  }

  // ✅ BUILD MUST BE HERE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
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

                const SizedBox(height: 20),

                // 🖼 IMAGE PREVIEW (TOP OF VIEW)
                if (_image != null)
                  FutureBuilder<Uint8List>(
                    future: _image!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const CircularProgressIndicator();
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          snapshot.data!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 25),

                // ⭐ SPECIAL OFFERS
                const Text(
                  "Special Offers",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                SpecialOfferCard(
                  imagePath: "assets/images/special_offer.jpg",
                  title: "30% OFF on Nike Sneakers!",
                  heightRatio: 0.7,
                ),

                const SizedBox(height: 30),

                // 🔥 MOST POPULAR
                const Text(
                  "Most Popular",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 160,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      PopularSneakerCard(
                        "Nike Air Max",
                        "assets/images/nike-air-max.png",
                      ),
                      PopularSneakerCard(
                        "Yeezy Boost",
                        "assets/images/yeezy-bost.png",
                      ),
                      PopularSneakerCard(
                        "Air Jordan 4",
                        "assets/images/air-jordan-4.png",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 📸 Floating scan button
          Positioned(
            top: 20,
            right: 20,
            child: SneakerScanButton(onTap: pickImage),
          ),

          // ⏳ LOADING OVERLAY
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
